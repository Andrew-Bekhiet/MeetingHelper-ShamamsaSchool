import { FieldValue, v1 } from "@google-cloud/firestore";
import { firestore, storage } from "firebase-admin";
import { region, runWith } from "firebase-functions";

type StudyYear = {
  Name: string;
  Grade: number;
  IsCollegeYear: boolean;
};

type StudyYearWithRef = {
  data: StudyYear;
  ref: firestore.DocumentReference;
};

type Class = {
  Name: string;
  StudyYearFrom: firestore.DocumentReference<StudyYear>;
  StudyYearTo: firestore.DocumentReference<StudyYear>;
};

type ClassWithRef = {
  data: Class;
  ref: firestore.DocumentReference;
};

type Person = {
  Name: string;
  ClassId: firestore.DocumentReference;
  StudyYear: firestore.DocumentReference;
};

type PersonWithRef = {
  data: Person;
  ref: firestore.DocumentReference;
};

export const doBackupFirestoreData = runWith({
  timeoutSeconds: 540,
  memory: "1GB",
})
  .region("europe-west6")
  .pubsub.schedule("0 0 * * 0")
  .onRun(async () => {
    const client = new v1.FirestoreAdminClient();
    const projectId = process.env.GCP_PROJECT || process.env.GCLOUD_PROJECT;
    const databaseName = client.databasePath(projectId!, "(default)");
    const timestamp = new Date().toISOString();

    console.log(
      `Starting backup project ${projectId} database ${databaseName} with name ${timestamp}`
    );

    return client
      .exportDocuments({
        name: databaseName,
        outputUriPrefix: `gs://${projectId}-firestore-backup/${timestamp}`,
        collectionIds: [],
      })
      .catch((err: any) => {
        console.error(err);
        throw new Error("Export operation failed");
      });
  });

export const deleteStaleData = runWith({
  timeoutSeconds: 540,
  memory: "1GB",
})
  .region("europe-west6")
  .pubsub.schedule("0 1 * * 0")
  .onRun(async () => {
    const projectId = process.env.GCP_PROJECT || process.env.GCLOUD_PROJECT;

    if (new Date().getDate() <= 7) {
      const writer = firestore().bulkWriter();
      writer.onWriteResult(async (ref) => {
        if (
          ref.path.match(/^Deleted\/\d{4}-\d{2}-\d{2}\/([^\\/])+\/([^\\/])+$/)
        ) {
          const entityRef = firestore().collection(ref.parent.id).doc(ref.id);

          if ((await entityRef.get()).exists) return;

          await firestore().recursiveDelete(entityRef, writer);

          if (ref.parent.id == "Services") {
            let pendingChanges = firestore().batch();

            const docs = [
              ...(
                await firestore()
                  .collection("Persons")
                  .where("Services", "array-contains", entityRef)
                  .get()
              ).docs,
              ...(
                await firestore()
                  .collection("UsersData")
                  .where("Services", "array-contains", entityRef)
                  .get()
              ).docs,
            ];
            for (let i = 0, l = docs.length; i < l; i++) {
              if ((i + 1) % 500 === 0) {
                await pendingChanges.commit();
                pendingChanges = firestore().batch();
              }
              if (
                !(docs[i].data().ClassId as
                  | firestore.DocumentReference
                  | null
                  | undefined) &&
                !(
                  docs[i].data().Services as
                    | Array<firestore.DocumentReference>
                    | null
                    | undefined
                )?.filter((r) => !r.isEqual(entityRef))?.length
              )
                pendingChanges.delete(docs[i].ref);
              else
                pendingChanges.update(docs[i].ref, {
                  Services: FieldValue.arrayRemove(entityRef),
                });
            }

            await pendingChanges.commit();

            pendingChanges = firestore().batch();

            const usersData = (
              await firestore()
                .collection("UsersData")
                .where("Services", "array-contains", entityRef)
                .get()
            ).docs;

            for (let i = 0; i < usersData.length; i++) {
              if ((i + 1) % 500 === 0) {
                await pendingChanges.commit();
                pendingChanges = firestore().batch();
              }
              pendingChanges.update(usersData[i].ref, {
                Services: FieldValue.arrayRemove(entityRef),
              });
            }
            await pendingChanges.commit();
          } else if (ref.parent.id == "Classes") {
            let pendingChanges = firestore().batch();

            const snapshot = await firestore()
              .collection("Persons")
              .where("ClassId", "==", entityRef)
              .get();
            for (let i = 0, l = snapshot.docs.length; i < l; i++) {
              if ((i + 1) % 500 === 0) {
                await pendingChanges.commit();
                pendingChanges = firestore().batch();
              }
              if (
                !(
                  snapshot.docs[i].data().Services as
                    | Array<firestore.DocumentReference>
                    | null
                    | undefined
                )?.length
              )
                pendingChanges.delete(snapshot.docs[i].ref);
              else
                pendingChanges.update(snapshot.docs[i].ref, {
                  ClassId: null,
                });
            }
          } else if (ref.parent.id == "Persons") {
            let deleteBatch = firestore().batch();

            const historyToDelete = [
              ...(
                await firestore()
                  .collectionGroup("Meeting")
                  .where("ID", "==", entityRef.id)
                  .get()
              ).docs,
              ...(
                await firestore()
                  .collectionGroup("Confession")
                  .where("ID", "==", entityRef.id)
                  .get()
              ).docs,
              ...(
                await firestore()
                  .collectionGroup("Kodas")
                  .where("ID", "==", entityRef.id)
                  .get()
              ).docs,
            ];

            let batchCount = 0;
            for (
              let i = 0, l = historyToDelete.length;
              i < l;
              i++, batchCount++
            ) {
              if (batchCount % 500 === 0) {
                await deleteBatch.commit();
                deleteBatch = firestore().batch();
              }
              deleteBatch.delete(historyToDelete[i].ref);
            }
            await deleteBatch.commit();
          }
        }
      });

      await storage()
        .bucket("gs://" + projectId + ".appspot.com")
        .deleteFiles({ prefix: "Exports/{export}" });
      await storage()
        .bucket("gs://" + projectId + ".appspot.com")
        .deleteFiles({ prefix: "Imports/{import}" });
      await storage()
        .bucket("gs://" + projectId + ".appspot.com")
        .deleteFiles({ prefix: "Deleted/{delete}" });
      await firestore().recursiveDelete(
        firestore().collection("Deleted"),
        writer
      );
    }
  });
export const updateStudyYears = region("europe-west6")
  .pubsub.schedule("0 0 11 9 *")
  .onRun(async () => {
    const result = await firestore().runTransaction(async (transaction) => {
      const studyYears = await transaction.get(
        firestore().collection("StudyYears").orderBy("Grade")
      );
      const firstYear = studyYears.docs[0].data();
      const lastYear = studyYears.docs[studyYears.docs.length - 1];

      for (let index = 1; index < studyYears.docs.length; index++) {
        transaction.update(
          studyYears.docs[index - 1].ref,
          studyYears.docs[index].data()
        );
      }

      transaction.set(firestore().collection("StudyYears").doc(), firstYear);
      transaction.update(lastYear.ref, {
        Grade: lastYear.data().Grade + 1,
        Name: "{تم ترحيل السنة برجاء ادخال اسم}",
        IsCollegeYear: lastYear.data().Grade + 1 > 12,
      });

      return true;
    });

    if (result) {
      console.log("Successfully updated study years");

      await fixClassesStudyYears();
    } else {
      console.error("Failed to update study years");
      throw new Error("Failed to update study years");
    }
  });

async function fixClassesStudyYears() {
  // -1 year from all classes study year range
  // move persons from each class to next using study year as a guide

  const result = await firestore().runTransaction(async (transaction) => {
    const studyYears = (
      await transaction.get(
        firestore().collection("StudyYears").orderBy("Grade")
      )
    ).docs.map(
      (doc) =>
        ({ ref: doc.ref, data: doc.data() as StudyYear } as StudyYearWithRef)
    );

    const classes = (
      await transaction.get(
        firestore().collection("Classes").orderBy("StudyYearFrom")
      )
    ).docs.map(
      (doc) => ({ ref: doc.ref, data: doc.data() as Class } as ClassWithRef)
    );

    const studyYearsByGrade = new Map<number, StudyYearWithRef>();
    const studyYearsByPath = new Map<string, StudyYearWithRef>();

    const classOldStudyYearTo = new Map<string, string>();
    const studyYearNewClass = new Map<string, string>();

    const classesUpdates = new Map<
      string,
      {
        StudyYearFrom: firestore.DocumentReference;
        StudyYearTo: firestore.DocumentReference;
      }
    >();

    for (const studyYear of studyYears) {
      studyYearsByGrade.set(studyYear.data.Grade, studyYear);
      studyYearsByPath.set(studyYear.ref.path, studyYear);
    }

    console.dir(studyYearsByPath);

    for (const $class of classes) {
      const from = studyYearsByPath.get($class.data.StudyYearFrom?.path)!;
      const to = studyYearsByPath.get($class.data.StudyYearTo?.path)!;

      if (from && to) {
        const newFrom = studyYearsByGrade.get(from.data.Grade - 1)!;
        const newTo = studyYearsByGrade.get(to.data.Grade - 1)!;

        console.log(
          `Updating class ${$class.ref.path} range from ${from.ref.path} -> ${to.ref.path} to ${newFrom.ref.path} -> ${newTo.ref.path}`
        );

        classOldStudyYearTo.set($class.ref.path, to.ref.path);
        studyYearNewClass.set(newFrom.ref.path, $class.ref.path);

        // Delay the update until all reads are done
        classesUpdates.set($class.ref.path, {
          StudyYearFrom: newFrom.ref,
          StudyYearTo: newTo.ref,
        });
      } else {
        console.log(
          `Skipping class ${$class.data.Name} because of missing study years, got ${from?.data.Grade} and ${to?.data.Grade}`
        );
      }
    }

    const persons = (
      await transaction.get(
        firestore()
          .collection("Persons")
          .where(
            "StudyYear",
            "in",
            Array.from(studyYearNewClass.keys()).map((s) => firestore().doc(s))
          )
      )
    ).docs
      .map(
        (doc) => ({ ref: doc.ref, data: doc.data() as Person } as PersonWithRef)
      )
      .filter((p) => p.data.ClassId);

    const oldClassToNewClass = new Map<string, string | undefined>();

    for (const [classPath, oldStudyYearRef] of classOldStudyYearTo) {
      oldClassToNewClass.set(classPath, studyYearNewClass.get(oldStudyYearRef));

      console.log(
        `Will move persons from ${classPath} to ${studyYearNewClass.get(
          oldStudyYearRef
        )}`
      );
    }

    for (const [path, data] of classesUpdates) {
      console.log(
        `Updating ${path}, new range: (${data.StudyYearFrom.path} -> ${data.StudyYearTo.path})`
      );
      await transaction.update(firestore().doc(path), data);
    }

    if (persons.length < 500 - classesUpdates.size) {
      await migratePersonsToNewClasses(
        persons,
        oldClassToNewClass,
        (ref, data) => transaction.update(ref, data),
        (ref, data) => transaction.create(ref, data)
      );

      return null;
    } else {
      return {
        persons,
        oldClassToNewClass,
      };
    }
  });

  if (result) {
    const { persons, oldClassToNewClass } = result;

    const batchWrapper = [firestore().batch()];

    await migratePersonsToNewClasses(
      persons,
      oldClassToNewClass,
      (ref, data) => batchWrapper[0].update(ref, data),
      (ref, data) => batchWrapper[0].create(ref, data),
      async () => {
        console.log("Committing a batch of 500");

        await batchWrapper[0].commit();

        batchWrapper[0] = firestore().batch();
      }
    );

    await batchWrapper[0].commit();
  }
}
async function migratePersonsToNewClasses(
  persons: {
    ref: firestore.DocumentReference<
      firestore.DocumentData,
      firestore.DocumentData
    >;
    data: Person;
  }[],
  oldClassToNewClass: Map<string, string | undefined>,
  update: (
    documentRef: firestore.DocumentReference,
    data: firestore.UpdateData<firestore.DocumentData>
  ) => any,
  create: (
    documentRef: firestore.DocumentReference,
    data: firestore.DocumentData
  ) => any,
  commit?: () => Promise<any>
) {
  const chunks = persons.reduce(
    (chunks, person) => {
      if (chunks.length === 0 || chunks[chunks.length - 1].length === 500) {
        return [...chunks, [person]];
      }

      return [...chunks.slice(0, -1), [...chunks[chunks.length - 1], person]];
    },
    new Array<
      Array<{
        ref: firestore.DocumentReference<
          firestore.DocumentData,
          firestore.DocumentData
        >;
        data: Person;
      }>
    >()
  );

  const newExtraClassTemplate = {
    Name: "{تم الترحيل لفصل جديد برجاء إدخال اسم}",
    HasPhoto: false,
    StudyYearFrom: undefined,
    StudyYearTo: undefined,
  };

  for (const chunk of chunks) {
    for (const person of chunk) {
      const newClass = oldClassToNewClass.get(person.data.ClassId?.path);

      console.log(
        `Updating ClassId of ${person.data.Name} ${person.ref.id}, from ${person.data.ClassId.path} to ${newClass}`
      );

      if (newClass) {
        await update(person.ref, {
          ClassId: firestore().doc(newClass),
        });
      } else {
        console.log(
          `Found ${person.data.Name} ${person.ref.id} with no new class, creating a new one`
        );

        const newClassId = firestore().collection("Classes").doc();
        await create(newClassId, {
          ...newExtraClassTemplate,
          StudyYearFrom: person.data.StudyYear,
          StudyYearTo: person.data.StudyYear,
        });

        await update(person.ref, { ClassId: newClassId });

        oldClassToNewClass.set(person.data.ClassId?.path, newClassId.path);
        console.log(
          `Created new class ${newClassId.path} and added it to the map\n` +
            `${person.data.ClassId} -> ${newClassId}`
        );
      }
    }

    await commit?.();
  }
}

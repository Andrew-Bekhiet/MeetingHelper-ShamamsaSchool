import { auth, firestore } from "firebase-admin";
import { https } from "firebase-functions";
import { adminPassword } from "./environment";

export const migrateFromV6 = https.onCall(async (data) => {
  if (data.AdminPassword !== adminPassword)
    throw new https.HttpsError("unauthenticated", "unauthenticated");

  console.log("Migrating Users claims...");

  if (data.sss) {
    const { users } = await auth().listUsers();
    const promises = [];

    for (const user of users) {
      const newClaims: Record<string, any> = {
        password: null, //Empty password
        manageUsers: false, //Can manage Users' names, reset passwords and permissions
        manageAllowedUsers: false, //Can manage specific Users' names, reset passwords and permissions
        manageDeleted: false, //Can read deleted items and restore them
        superAccess: false, //Can read everything
        write: true, //Can write avalibale data
        secretary: false, //Can write servants history
        changeHistory: false,
        export: user.customClaims?.exportClasses
          ? user.customClaims!.exportClasses!
          : true, //Can Export individual Classes to Excel sheet
        birthdayNotify: true, //Can receive Birthday notifications
        confessionsNotify: true,
        tanawolNotify: true,
        kodasNotify: true,
        meetingNotify: true,
        visitNotify: true,
        approved: false, //A User with 'Manage Users' permission must approve new users
        lastConfession: null, //Last Confession in millis for the user
        lastTanawol: null, //Last Tanawol in millis for the user
        servingStudyYear: null,
        servingStudyGender: null,
        personId: firestore().collection("UsersData").doc().id,
        ...user.customClaims,
      };
      delete newClaims.exportClasses;
      delete newClaims.approveLocations;

      promises.push(auth().setCustomUserClaims(user.uid, newClaims));
    }
    await Promise.all(promises);

    console.log("Migrating Persons data...");
  }

  let batch = firestore().batch();
  let batchCount = 0;

  if (data.lengthsk == 0) {
    const classes: Record<string, firestore.QueryDocumentSnapshot> = (
      await firestore().collection("Classes").get()
    ).docs.reduce<Record<string, firestore.QueryDocumentSnapshot>>((map, c) => {
      map[c.id] = c;
      return map;
    }, {});

    const persons = (await firestore().collection("Persons").get()).docs;

    for (const person of persons) {
      if (!person.data().ClassId) {
        console.warn(
          "Skipped " + person.ref.id + "because it has null ClassId"
        );
        continue;
      }

      if (batchCount !== 0 && batchCount % 500 == 0) {
        console.log(await batch.commit());
        batch = firestore().batch();
      }
      console.log("Updating: " + person.id);
      console.log(
        "Class Data: " +
          classes[
            (person.data().ClassId as firestore.DocumentReference).id
          ]?.data()
      );

      batch.update(person.ref, {
        IsShammas: false,
        Gender: classes[
          (person.data().ClassId as firestore.DocumentReference).id
        ]?.data().Gender
          ? classes[
              (person.data().ClassId as firestore.DocumentReference).id
            ].data().Gender
          : false,
        ShammasLevel: null,
        StudyYear: classes[
          (person.data().ClassId as firestore.DocumentReference).id
        ]?.data().StudyYear
          ? classes[
              (person.data().ClassId as firestore.DocumentReference).id
            ].data().StudyYear
          : null,
        Services: [],
      });
      batchCount++;
    }
    console.log(await batch.commit());
  }

  console.log("Migrating History data...");

  batch = firestore().batch();

  const meeting = (await firestore().collectionGroup("Meeting").get()).docs;
  const kodas = (await firestore().collectionGroup("Kodas").get()).docs;

  for (const record of [...meeting, ...kodas]) {
    if (record.ref.parent.parent?.parent.id !== "ServantsHistory") continue;
    const newId = (
      await auth()
        .getUser(record.id)
        .catch(() => {
          return { customClaims: null };
        })
    ).customClaims?.personId;
    if (!newId) {
      console.warn("Skipping ", record.id, " because its user doesn\t exist");
      continue;
    }

    if (batchCount !== 0 && batchCount % 500 == 0) {
      console.log(await batch.commit());
      batch = firestore().batch();
    }
    console.log("Updating: " + record.id);
    console.log("New ID: ", newId, " Old ID:", record.id);

    batch.set(record.ref.parent.doc(newId), {
      ...record.data(),
      ID: newId,
    });
    batch.delete(record.ref);
    batchCount++;
  }
  console.log(await batch.commit());
});

export const migrateFromV7_2 = https.onCall(async (data) => {
  if (data.AdminPassword !== adminPassword)
    throw new https.HttpsError("unauthenticated", "unauthenticated");

  console.log("Migrating History data...");

  let batch = firestore().batch();
  let batchCount = 0;

  const meeting = (await firestore().collectionGroup("Meeting").get()).docs;
  const kodas = (await firestore().collectionGroup("Kodas").get()).docs;
  const confession = (await firestore().collectionGroup("Confession").get())
    .docs;

  const uidToUser: Record<string, auth.UserRecord | { customClaims: null }> =
    {};

  for (const record of [...meeting, ...kodas, ...confession]) {
    if (record.ref.parent.parent?.parent.id !== "ServantsHistory") continue;
    const newId = (uidToUser[record.id] ??= await auth()
      .getUser(record.id)
      .catch(() => {
        return { customClaims: null };
      })).customClaims?.personId;
    if (!newId) {
      console.warn("Skipping ", record.id, " because its user doesn\t exist");
      continue;
    }

    if (batchCount !== 0 && batchCount % 500 == 0) {
      console.log(await batch.commit());
      batch = firestore().batch();
    }
    console.log("Updating: " + record.id);
    console.log("New ID: ", newId, " Old ID:", record.id);

    batch.set(record.ref.parent.doc(newId), {
      ...record.data(),
      ID: newId,
    });
    batch.delete(record.ref);
    batchCount++;
  }
  console.log(await batch.commit());
});

function split<T>(arry: Array<T>, length: number): Array<Array<T>> {
  const chunks: Array<Array<T>> = [];

  for (let i = 0; i < arry.length; i++) {
    chunks.push(
      arry.splice(i, i + length > arry.length ? arry.length : i + length)
    );
  }
  return chunks;
}

export async function migrateDates() {
  const persons = await firestore()
    .collection("Persons")
    .where("BirthDate", "!=", null)
    .get();

  const updates = persons.docs.map((p) => {
    const birthDate = p.data()["BirthDate"]!.toDate()!;
    const birthDay = p.data()["BirthDay"]!.toDate()!;

    console.log("Scheduled update for ", p.id);
    console.dir({
      Name: p.data().Name,
      BirthDate: birthDate,
      BirthDay: birthDay,
    });

    return p.ref.update({
      BirthDate: toNearestDay(birthDate),
      BirthDay: toNearestDay(birthDay),
    });
  });

  // Split into batches of 500 then issue all updates in parallel
  const batches = split(
    updates.filter((u) => u != null && u != undefined),
    500
  );
  for (const batch of batches) {
    await Promise.all(batch);
  }

  console.log("Done");

  return "OK";
}

export async function migrateDates2() {
  const persons = await firestore()
    .collection("Persons")
    .where("BirthDate", "!=", null)
    .get();

  const updates = persons.docs.map((p) => {
    const birthDate: Date = p.data()["BirthDate"]!.toDate()!;
    const birthDay: Date = p.data()["BirthDay"]!.toDate()!;

    if (birthDate.getUTCDate() == 1) {
      birthDate.setUTCMonth(birthDate.getUTCMonth() + 1);
      birthDay.setUTCMonth(birthDay.getUTCMonth() + 1);

      console.log("Scheduled update for ", p.id);
      console.dir({
        Name: p.data().Name,
        BirthDate: birthDate,
        BirthDay: birthDay,
      });
      return p.ref.update({
        BirthDate: toNearestDay(birthDate),
        BirthDay: toNearestDay(birthDay),
      });
    } else {
      console.log("Skipped ", p.id);
      return null;
    }
  });

  // Split into batches of 500 then issue all updates in parallel
  const batches = split(
    updates.filter((u) => u != null && u != undefined),
    500
  );
  for (const batch of batches) {
    await Promise.all(batch);
  }

  console.log("Done");

  return "OK";
}

function toNearestDay(date: Date): Date {
  date.setUTCDate(date.getUTCDate() + (date.getUTCHours() >= 12 ? 1 : 0));
  date.setUTCHours(6);
  date.setUTCMinutes(0);
  date.setUTCSeconds(0);
  date.setUTCMilliseconds(0);
  return date;
}

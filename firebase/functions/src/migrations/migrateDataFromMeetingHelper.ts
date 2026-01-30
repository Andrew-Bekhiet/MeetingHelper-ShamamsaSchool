/**
 * Grade groups for class consolidation.
 * Each group will become a single consolidated class.
 */
const gradeGroups = [
  { grades: [-2, -1, 0], name: "Baby Class" },
  { grades: [1, 2], name: "أولى وتانية" },
  { grades: [3, 4], name: "تالتة ورابعة" },
  { grades: [5, 6], name: "خامسة وسادسة" },
  { grades: [7, 8, 9], name: "اعدادي" },
  { grades: [10, 11, 12], name: "ثانوي" },
  { grades: [13, 14, 15, 16], name: "جامعة" },
];

/**
 * Consolidates classes by grade ranges.
 *
 * Old format: Each class has a single `StudyYear` (doc ref)
 * New format: Each class has `StudyYearFrom` and `StudyYearTo` (doc refs)
 *
 * This migration:
 * 1. Creates new consolidated classes for each grade group
 * 2. Updates all Person documents to point to the new consolidated classes
 * 3. Deletes the old classes
 */
export async function consolidateClasses(dryRun = false) {
  console.log(`Starting class consolidation migration (dryRun: ${dryRun})...`);

  // Step 1: Fetch all StudyYears and build grade -> StudyYear ref map
  console.log("Fetching StudyYears...");
  const studyYearsSnapshot = await firestore().collection("StudyYears").get();
  const gradeToStudyYearRef: Record<number, firestore.DocumentReference> = {};
  const studyYearRefToGrade: Record<string, number> = {};

  for (const doc of studyYearsSnapshot.docs) {
    const grade = doc.data().Grade as number;
    gradeToStudyYearRef[grade] = doc.ref;
    studyYearRefToGrade[doc.ref.path] = grade;
    console.log(`  Grade ${grade} -> ${doc.ref.path}`);
  }

  // Step 2: Fetch all existing Classes
  console.log("Fetching existing Classes...");
  const classesSnapshot = await firestore().collection("Classes").get();
  const oldClasses = classesSnapshot.docs;
  console.log(`  Found ${oldClasses.length} classes`);

  // Step 3: Create mapping from old class ID to grade
  const oldClassIdToGrade: Record<string, number> = {};
  for (const classDoc of oldClasses) {
    const studyYearRef = classDoc.data().StudyYear as
      | firestore.DocumentReference
      | undefined;
    if (studyYearRef) {
      const grade = studyYearRefToGrade[studyYearRef.path];
      if (grade !== undefined) {
        oldClassIdToGrade[classDoc.id] = grade;
        console.log(
          `  Class "${classDoc.data().Name}" (${classDoc.id}) -> Grade ${grade}`,
        );
      } else {
        console.warn(
          `  Class "${classDoc.data().Name}" (${classDoc.id}) has unknown StudyYear ref: ${studyYearRef.path}`,
        );
      }
    } else {
      console.warn(
        `  Class "${classDoc.data().Name}" (${classDoc.id}) has no StudyYear`,
      );
    }
  }

  // Step 4: Create new consolidated classes and build mapping
  console.log("Creating consolidated classes...");
  const oldClassIdToNewClassRef: Record<string, firestore.DocumentReference> =
    {};

  let batch = firestore().batch();
  let batchCount = 0;

  for (const group of gradeGroups) {
    const minGrade = Math.min(...group.grades);
    const maxGrade = Math.max(...group.grades);

    const studyYearFromRef = gradeToStudyYearRef[minGrade];
    const studyYearToRef = gradeToStudyYearRef[maxGrade];

    if (!studyYearFromRef || !studyYearToRef) {
      console.warn(
        `  Skipping group "${group.name}" - missing StudyYear refs for grades ${minGrade} or ${maxGrade}`,
      );
      continue;
    }

    // Create new consolidated class
    const newClassRef = firestore().collection("Classes").doc();
    const newClassData = {
      Name: group.name,
      StudyYearFrom: studyYearFromRef,
      StudyYearTo: studyYearToRef,
      Gender: null, // Both genders
      HasPhoto: false,
      Color: null,
      Allowed: [],
      LastEdit: null,
      LastEditTime: null,
    };

    console.log(
      `  Creating class "${group.name}" (${newClassRef.id}) for grades ${minGrade}-${maxGrade}`,
    );

    if (!dryRun) {
      batch.set(newClassRef, newClassData);
      batchCount++;
    }

    // Map old classes to new class
    for (const [oldClassId, grade] of Object.entries(oldClassIdToGrade)) {
      if (group.grades.includes(grade)) {
        oldClassIdToNewClassRef[oldClassId] = newClassRef;
        console.log(
          `    Mapping old class ${oldClassId} -> new class ${newClassRef.id}`,
        );
      }
    }
  }

  if (!dryRun && batchCount > 0) {
    console.log(`Committing batch with ${batchCount} new classes...`);
    await batch.commit();
  }

  // Step 5: Update all Persons to point to new classes
  console.log("Updating Person documents...");
  const personsSnapshot = await firestore().collection("Persons").get();
  console.log(`  Found ${personsSnapshot.docs.length} persons`);

  batch = firestore().batch();
  batchCount = 0;
  let updatedCount = 0;
  let skippedCount = 0;

  for (const personDoc of personsSnapshot.docs) {
    const classId = personDoc.data().ClassId as
      | firestore.DocumentReference
      | undefined;

    if (!classId) {
      console.log(`  Skipping person ${personDoc.id} - no ClassId`);
      skippedCount++;
      continue;
    }

    const newClassRef = oldClassIdToNewClassRef[classId.id];
    if (!newClassRef) {
      console.warn(
        `  Skipping person ${personDoc.id} - no mapping for class ${classId.id}`,
      );
      skippedCount++;
      continue;
    }

    if (!dryRun) {
      batch.update(personDoc.ref, { ClassId: newClassRef });
      batchCount++;

      if (batchCount % 500 === 0) {
        console.log(`  Committing batch of 500 person updates...`);
        await batch.commit();
        batch = firestore().batch();
      }
    }
    updatedCount++;
  }

  if (!dryRun && batchCount > 0) {
    console.log(`  Committing final batch of ${batchCount} person updates...`);
    await batch.commit();
  }

  console.log(
    `  Updated ${updatedCount} persons, skipped ${skippedCount} persons`,
  );

  // Step 6: Delete old classes
  console.log("Deleting old classes...");
  batch = firestore().batch();
  batchCount = 0;
  let deletedCount = 0;

  for (const classDoc of oldClasses) {
    // Only delete classes that were mapped to new ones
    if (oldClassIdToNewClassRef[classDoc.id]) {
      if (!dryRun) {
        batch.delete(classDoc.ref);
        batchCount++;

        if (batchCount % 500 === 0) {
          console.log(`  Committing batch of 500 class deletions...`);
          await batch.commit();
          batch = firestore().batch();
        }
      }
      deletedCount++;
    }
  }

  if (!dryRun && batchCount > 0) {
    console.log(`  Committing final batch of ${batchCount} class deletions...`);
    await batch.commit();
  }

  console.log(`  Deleted ${deletedCount} old classes`);

  console.log("Class consolidation migration complete!");
  return {
    newClassesCreated: gradeGroups.length,
    personsUpdated: updatedCount,
    personsSkipped: skippedCount,
    oldClassesDeleted: deletedCount,
  };
}

/**
 * Cleans up orphaned user data from Firestore.
 *
 * Deletes documents from:
 * - `UsersData` collection where the `UID` field doesn't match any authenticated user
 * - `Users` collection where the document ID doesn't match any authenticated user UID
 */
export async function cleanupOrphanedUsers(dryRun = false) {
  console.log(`Starting orphaned user cleanup (dryRun: ${dryRun})...`);

  // Step 1: Get all authenticated users from Firebase Auth
  console.log("Fetching authenticated users from Firebase Auth...");
  const allUsers: auth.UserRecord[] = [];
  let nextPageToken: string | undefined;

  // Handle pagination for large user bases
  do {
    const listResult = await auth().listUsers(1000, nextPageToken);
    allUsers.push(...listResult.users);
    nextPageToken = listResult.pageToken;
  } while (nextPageToken);

  const validUids = new Set(allUsers.map((u) => u.uid));
  console.log(`  Found ${validUids.size} authenticated users`);

  let batch = firestore().batch();
  let batchCount = 0;

  // Step 2: Delete orphaned UsersData documents
  console.log("Checking UsersData collection...");
  const usersDataSnapshot = await firestore().collection("UsersData").get();
  console.log(`  Found ${usersDataSnapshot.docs.length} UsersData documents`);

  let usersDataDeletedCount = 0;
  for (const doc of usersDataSnapshot.docs) {
    const uid = doc.data().UID as string | undefined;

    if (!uid || !validUids.has(uid)) {
      console.log(
        `  Deleting orphaned UsersData document ${doc.id} (UID: ${uid || "null"})`,
      );

      if (!dryRun) {
        batch.delete(doc.ref);
        batchCount++;

        if (batchCount % 500 === 0) {
          console.log(`  Committing batch of 500 deletions...`);
          await batch.commit();
          batch = firestore().batch();
          batchCount = 0;
        }
      }
      usersDataDeletedCount++;
    }
  }

  // Step 3: Delete orphaned Users documents
  console.log("Checking Users collection...");
  const usersSnapshot = await firestore().collection("Users").get();
  console.log(`  Found ${usersSnapshot.docs.length} Users documents`);

  let usersDeletedCount = 0;
  for (const doc of usersSnapshot.docs) {
    // Document ID is the UID
    if (!validUids.has(doc.id)) {
      console.log(`  Deleting orphaned Users document ${doc.id}`);

      if (!dryRun) {
        batch.delete(doc.ref);
        batchCount++;

        if (batchCount % 500 === 0) {
          console.log(`  Committing batch of 500 deletions...`);
          await batch.commit();
          batch = firestore().batch();
          batchCount = 0;
        }
      }
      usersDeletedCount++;
    }
  }

  // Commit any remaining operations
  if (!dryRun && batchCount > 0) {
    console.log(`  Committing final batch of ${batchCount} deletions...`);
    await batch.commit();
  }

  console.log("Orphaned user cleanup complete!");
  console.log(`  UsersData documents deleted: ${usersDataDeletedCount}`);
  console.log(`  Users documents deleted: ${usersDeletedCount}`);

  return {
    authenticatedUsersCount: validUids.size,
    usersDataDeleted: usersDataDeletedCount,
    usersDeleted: usersDeletedCount,
  };
}

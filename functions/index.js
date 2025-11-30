const { firestore } = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.updateRatingOnReviewChange = firestore.onDocumentWritten(
  {
    document: "reviews/{reviewId}",
    region: "asia-southeast2",
  },
  async (event) => {
    const after = event.data.after ? event.data.after.data() : null;
    const before = event.data.before ? event.data.before.data() : null;

    // Ambil foodID dari after (update/create) atau before (delete)
    const foodID = after ? after.foodID : before?.foodID;

    if (!foodID) {
      console.log("No foodID found. Skipping update.");
      return null;
    }

    // Ambil semua review yang terkait dengan foodID ini
    const snap = await db
      .collection("reviews")
      .where("foodID", "==", foodID)
      .get();

    let sum = 0;
    snap.forEach((doc) => {
      sum += doc.data().rating;
    });

    const count = snap.size;
    const average = count > 0 ? sum / count : 0;

    // Update ke collection foods
    await db.collection("foods").doc(foodID).update({
      averageRating: average,
      ratingsCount: count,
    });

    console.log(`Updated food ${foodID}: avg=${average}, count=${count}`);

    return null;
  }
);

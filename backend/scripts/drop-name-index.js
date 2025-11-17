// Script to drop the unique index on the 'name' field in the users collection
// Run this once to fix the duplicate key error when updating profiles
// Usage: node scripts/drop-name-index.js

const mongoose = require("mongoose");
const dotenv = require("dotenv");
dotenv.config();

const connectDB = require("../config/db");

async function dropNameIndex() {
  try {
    await connectDB();
    console.log("✅ Connected to database");

    const db = mongoose.connection.db;
    const collection = db.collection("users");

    // List all indexes
    const indexes = await collection.indexes();
    console.log("Current indexes:", indexes);

    // Drop the unique index on 'name' if it exists
    try {
      await collection.dropIndex("name_1");
      console.log("✅ Successfully dropped 'name_1' index");
    } catch (err) {
      if (err.code === 27 || err.message.includes("index not found")) {
        console.log("ℹ️  'name_1' index does not exist (already removed or never created)");
      } else {
        throw err;
      }
    }

    // Verify indexes after dropping
    const indexesAfter = await collection.indexes();
    console.log("Indexes after drop:", indexesAfter);

    console.log("✅ Done! You can now update profiles without name uniqueness conflicts.");
    process.exit(0);
  } catch (error) {
    console.error("❌ Error:", error);
    process.exit(1);
  }
}

dropNameIndex();


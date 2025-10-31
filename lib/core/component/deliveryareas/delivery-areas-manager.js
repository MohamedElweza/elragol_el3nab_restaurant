/**
 * Delivery Areas Manager
 * Adds delivery areas to the API and verifies they were created successfully
 * 
 * IMPORTANT: This script needs to be run on a machine that has access to your ngrok tunnel.
 * The ngrok URL may not be accessible from all networks/environments.
 * 
 * To run this script:
 * 1. Make sure your ngrok tunnel is running and accessible
 * 2. Update the API_BASE_URL, ACCESS_TOKEN, and API_KEY if needed
 * 3. Run: node delivery-areas-manager.js
 */

import fetch from 'node-fetch';

// Configuration
const API_BASE_URL = 'https://c8ee04b37e9b.ngrok-free.app/api/v1/admin';
const ACCESS_TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2OTAxNDg4OGU4M2UxMzg2MDExOTc4ZTUiLCJpYXQiOjE3NjE2OTI3NTR9.YaozXiuzOlCUP3TV1dguGcdcyb21HF3qks7bWZRIgxg';
const API_KEY = 'ca36503d5358b81d9c3d0242738362f0';

// Delivery areas to add (name and deliveryFee in Arabic)
const DELIVERY_AREAS = [
  { name: 'سمنود', deliveryFee: 20 },
  { name: 'جراح', deliveryFee: 40 },
  { name: 'الناصريه', deliveryFee: 35 },
  { name: 'ابوصير', deliveryFee: 50 },
  { name: 'بنا ابو صير', deliveryFee: 75 },
  { name: 'ميت حبيب', deliveryFee: 85 },
  { name: 'ميت بدر', deliveryFee: 95 },
  { name: 'العجزيه', deliveryFee: 120 },
  { name: 'المحله', deliveryFee: 75 },
  { name: 'ابو علي', deliveryFee: 50 },
  { name: 'الراهبين', deliveryFee: 40 },
  { name: 'منيا', deliveryFee: 25 },
  { name: 'اجا', deliveryFee: 55 },
  { name: 'الديرس', deliveryFee: 55 },
  { name: 'نوسه البحر', deliveryFee: 90 },
  { name: 'نوسه الغيط', deliveryFee: 90 },
  { name: 'كفر التعابنيه', deliveryFee: 40 },
  { name: 'محله خلف', deliveryFee: 40 },
  { name: 'الناوية', deliveryFee: 50 },
  { name: 'عساس', deliveryFee: 60 },
  { name: 'بهبيت', deliveryFee: 75 },
  { name: 'طليمه', deliveryFee: 75 },
  { name: 'كفر حسان', deliveryFee: 70 },
  { name: 'كفر العرب', deliveryFee: 130 },
  { name: 'الجمزتين', deliveryFee: 25 },
  { name: 'منيا سمنود', deliveryFee: 25 },
  { name: 'سنبخت', deliveryFee: 55 }
];

// Default estimated time for all areas (in minutes)
const DEFAULT_ESTIMATED_TIME = 30;

// Delay between requests to avoid rate limiting
const DELAY_BETWEEN_REQUESTS = 1000; // 1 second

// ========================================
// HELPER FUNCTIONS
// ========================================

function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// ========================================
// API FUNCTIONS
// ========================================

async function createDeliveryArea(areaData) {
  try {
    const response = await fetch(`${API_BASE_URL}/deliveryAreas`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${ACCESS_TOKEN}`,
        'X-API-Key': API_KEY,
        'ngrok-skip-browser-warning': 'true'
      },
      body: JSON.stringify({
        name: areaData.name,
        deliveryFee: areaData.deliveryFee,
        estimatedTime: areaData.estimatedTime || DEFAULT_ESTIMATED_TIME
      })
    });

    const data = await response.json();
    
    if (response.ok) {
      return { success: true, data: data };
    } else {
      return { success: false, error: data };
    }

  } catch (error) {
    return { success: false, error: error.message };
  }
}

async function getAllDeliveryAreas() {
  try {
    const response = await fetch(`${API_BASE_URL}/deliveryAreas`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${ACCESS_TOKEN}`,
        'X-API-Key': API_KEY,
        'ngrok-skip-browser-warning': 'true'
      }
    });

    const data = await response.json();
    
    if (response.ok) {
      return { success: true, data: data.data.deliveryAreas };
    } else {
      return { success: false, error: data };
    }

  } catch (error) {
    return { success: false, error: error.message };
  }
}

// ========================================
// MAIN FUNCTIONS
// ========================================

async function addAllDeliveryAreas() {
  console.log('\n🚀 Starting to add delivery areas...');
  console.log(`📋 Total areas to add: ${DELIVERY_AREAS.length}`);
  console.log('='.repeat(60));

  const results = {
    success: [],
    failed: [],
    skipped: []
  };

  for (let i = 0; i < DELIVERY_AREAS.length; i++) {
    const area = DELIVERY_AREAS[i];
    const progress = `[${i + 1}/${DELIVERY_AREAS.length}]`;
    
    console.log(`\n${progress} Adding: ${area.name} (Fee: ${area.deliveryFee} SAR)`);

    const result = await createDeliveryArea(area);

    if (result.success) {
      console.log(`   ✅ Success: ${area.name} added`);
      results.success.push({
        name: area.name,
        deliveryFee: area.deliveryFee,
        id: result.data.data?.deliveryArea?._id
      });
    } else {
      console.log(`   ❌ Failed: ${area.name}`);
      console.log(`   Error: ${JSON.stringify(result.error)}`);
      
      // Check if it's a duplicate error
      if (result.error && result.error.message && result.error.message.includes('already exists')) {
        console.log(`   ⚠️  Area already exists: ${area.name}`);
        results.skipped.push({
          name: area.name,
          deliveryFee: area.deliveryFee,
          reason: 'Already exists'
        });
      } else {
        results.failed.push({
          name: area.name,
          deliveryFee: area.deliveryFee,
          error: result.error
        });
      }
    }

    // Add delay between requests
    if (i < DELIVERY_AREAS.length - 1) {
      await delay(DELAY_BETWEEN_REQUESTS);
    }
  }

  return results;
}

async function verifyAllAreasAdded() {
  console.log('\n🔍 Verifying all delivery areas were added...');
  console.log('='.repeat(60));

  const result = await getAllDeliveryAreas();

  if (!result.success) {
    console.log('❌ Failed to fetch delivery areas:', result.error);
    return false;
  }

  const existingAreas = result.data;
  console.log(`📦 Total areas in database: ${existingAreas.length}`);

  // Check which areas from our list exist
  const foundAreas = [];
  const missingAreas = [];

  DELIVERY_AREAS.forEach(targetArea => {
    const found = existingAreas.find(existing => 
      existing.name.trim().toLowerCase() === targetArea.name.trim().toLowerCase()
    );

    if (found) {
      foundAreas.push({
        name: targetArea.name,
        deliveryFee: found.deliveryFee,
        expectedFee: targetArea.deliveryFee,
        id: found._id,
        isActive: found.isActive
      });
    } else {
      missingAreas.push(targetArea);
    }
  });

  console.log('\n✅ Areas found in database:');
  console.log('─'.repeat(60));
  foundAreas.forEach(area => {
    const feeMatch = area.deliveryFee === area.expectedFee ? '✅' : '⚠️';
    const status = area.isActive ? 'Active' : 'Inactive';
    console.log(`   ${feeMatch} ${area.name.padEnd(20)} Fee: ${area.deliveryFee} SAR (${status})`);
    
    if (area.deliveryFee !== area.expectedFee) {
      console.log(`      Expected: ${area.expectedFee} SAR`);
    }
  });

  if (missingAreas.length > 0) {
    console.log('\n❌ Missing areas:');
    console.log('─'.repeat(60));
    missingAreas.forEach(area => {
      console.log(`   ❌ ${area.name} (Expected fee: ${area.deliveryFee} SAR)`);
    });
  }

  console.log('\n📊 Summary:');
  console.log(`   Found: ${foundAreas.length}/${DELIVERY_AREAS.length}`);
  console.log(`   Missing: ${missingAreas.length}`);
  console.log(`   Total in DB: ${existingAreas.length}`);

  return missingAreas.length === 0;
}

async function displayAllAreas() {
  console.log('\n📋 All delivery areas in database:');
  console.log('='.repeat(80));

  const result = await getAllDeliveryAreas();

  if (!result.success) {
    console.log('❌ Failed to fetch delivery areas:', result.error);
    return;
  }

  const areas = result.data.sort((a, b) => a.deliveryFee - b.deliveryFee);

  console.log('\n🏪 All Delivery Areas (sorted by fee):');
  console.log('─'.repeat(80));
  console.log('Name'.padEnd(25) + 'Fee (SAR)'.padEnd(12) + 'Time (min)'.padEnd(12) + 'Status'.padEnd(10) + 'ID');
  console.log('─'.repeat(80));

  areas.forEach(area => {
    const status = area.isActive ? 'Active' : 'Inactive';
    console.log(
      `${area.name.padEnd(25)}${String(area.deliveryFee).padEnd(12)}${String(area.estimatedTime).padEnd(12)}${status.padEnd(10)}${area._id}`
    );
  });

  console.log(`\nTotal: ${areas.length} delivery areas`);
}

// ========================================
// MAIN EXECUTION
// ========================================

async function main() {
  try {
    console.log('\n🏪 Delivery Areas Manager');
    console.log('='.repeat(60));
    console.log(`📡 API Endpoint: ${API_BASE_URL}/deliveryAreas`);
    console.log(`🔑 Using API Key: ${API_KEY.substring(0, 8)}...`);
    console.log(`🎯 Areas to process: ${DELIVERY_AREAS.length}`);

    // Step 1: Add all delivery areas
    const addResults = await addAllDeliveryAreas();

    // Step 2: Show summary of additions
    console.log('\n📊 ADDITION SUMMARY');
    console.log('='.repeat(60));
    console.log(`✅ Successfully added: ${addResults.success.length}`);
    console.log(`⚠️  Skipped (already exist): ${addResults.skipped.length}`);
    console.log(`❌ Failed: ${addResults.failed.length}`);

    if (addResults.failed.length > 0) {
      console.log('\n❌ Failed areas:');
      addResults.failed.forEach(area => {
        console.log(`   - ${area.name}: ${JSON.stringify(area.error)}`);
      });
    }

    // Step 3: Verify all areas are in the database
    console.log('\n' + '='.repeat(60));
    const allAdded = await verifyAllAreasAdded();

    // Step 4: Display all areas
    await displayAllAreas();

    // Final status
    console.log('\n' + '='.repeat(60));
    if (allAdded) {
      console.log('✅ SUCCESS: All delivery areas have been added and verified!');
    } else {
      console.log('⚠️  WARNING: Some areas may be missing. Check the verification results above.');
    }
    console.log('='.repeat(60));

  } catch (error) {
    console.error('\n❌ Fatal error:', error.message);
    console.error(error);
    process.exit(1);
  }
}

// Run the script
main();
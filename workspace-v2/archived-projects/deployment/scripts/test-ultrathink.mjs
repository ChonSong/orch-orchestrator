#!/usr/bin/env node

import { UltraThinkOrchestrator } from './ultrathink-orchestrator.mjs';

async function testUltraThink() {
  console.log('🧪 Testing UltraThink v3.0...');

  try {
    const orchestrator = new UltraThinkOrchestrator({
      verbose: true,
      autoApprove: true
    });

    console.log('✅ UltraThink initialized successfully');

    // Test with a simple string
    console.log('🧪 Testing simple string input...');
    const result1 = await orchestrator.executeTask("test simple parsing");
    console.log('Result 1:', result1.success ? 'SUCCESS' : 'FAILED');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
    console.error('Stack:', error.stack);
  }
}

testUltraThink();
import sqlite3 from 'sqlite3';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';

const JWT_SECRET = process.env.JWT_SECRET || 'NC95wKP3QcAdhkOtAOKbESQUopOW9VAjy8gbrCVHsLY=';

// Create JWT token for admin user
const userId = 'f8c21b33-7d4b-4297-a59e-98dd365c8606';
const email = 'admin@codeovertcp.com';

const payload = {
  userId: userId,
  email: email,
  iat: Math.floor(Date.now() / 1000),
  exp: Math.floor(Date.now() / 1000) + (24 * 60 * 60) // 24 hours
};

const token = jwt.sign(payload, JWT_SECRET);

console.log('🔑 Temporary Admin Login Credentials');
console.log('=====================================');
console.log('Email:', email);
console.log('Password:', 'tempPass123!');
console.log('');
console.log('JWT Token (use for testing):');
console.log(token);
console.log('');
console.log('📝 NOTES:');
console.log('- Google OAuth implementation needed');
console.log('- Registration endpoint may need debugging');
console.log('- CORS might be blocking requests');
console.log('');
console.log('🔗 Test API endpoints:');
console.log('curl -H "Authorization: Bearer ' + token + '" \\');
console.log('     https://sync.codeovertcp.com/api/devices');
console.log('');
console.log('🌐 WebSocket connection:');
console.log('const socket = io("wss://sync.codeovertcp.com", {');
console.log('  auth: { token: "' + token + '" }');
console.log('});');
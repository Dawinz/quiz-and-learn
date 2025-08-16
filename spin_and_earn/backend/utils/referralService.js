const crypto = require('crypto');

/**
 * Generate a unique referral code
 * @param {number} length - Length of the referral code
 * @returns {string} - Generated referral code
 */
const generateReferralCode = (length = 8) => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let result = '';
  
  // Generate random code
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  
  return result;
};

/**
 * Generate multiple unique referral codes
 * @param {number} count - Number of codes to generate
 * @param {number} length - Length of each code
 * @returns {string[]} - Array of unique referral codes
 */
const generateMultipleReferralCodes = (count = 1, length = 8) => {
  const codes = new Set();
  
  while (codes.size < count) {
    codes.add(generateReferralCode(length));
  }
  
  return Array.from(codes);
};

/**
 * Validate referral code format
 * @param {string} code - Referral code to validate
 * @returns {boolean} - Whether the code is valid
 */
const validateReferralCodeFormat = (code) => {
  if (!code || typeof code !== 'string') return false;
  
  // Check length
  if (code.length < 6 || code.length > 10) return false;
  
  // Check if only contains valid characters
  const validChars = /^[A-Z0-9]+$/;
  return validChars.test(code);
};

/**
 * Calculate referral bonus for referrer
 * @param {number} baseAmount - Base bonus amount
 * @param {number} referralCount - Number of successful referrals
 * @returns {number} - Calculated bonus amount
 */
const calculateReferrerBonus = (baseAmount = 25, referralCount = 0) => {
  // Bonus increases with more referrals (tiered system)
  if (referralCount >= 10) return baseAmount * 2; // 50 coins for 10+ referrals
  if (referralCount >= 5) return baseAmount * 1.5; // 37.5 coins for 5+ referrals
  return baseAmount; // 25 coins for 1-4 referrals
};

/**
 * Calculate referral bonus for referred user
 * @param {number} baseAmount - Base bonus amount
 * @param {boolean} isFirstTime - Whether this is the user's first referral
 * @returns {number} - Calculated bonus amount
 */
const calculateReferredUserBonus = (baseAmount = 25, isFirstTime = true) => {
  return isFirstTime ? baseAmount : baseAmount * 0.5; // 25 for first time, 12.5 for subsequent
};

/**
 * Generate referral link
 * @param {string} referralCode - User's referral code
 * @param {string} baseUrl - Base URL of the application
 * @returns {string} - Complete referral link
 */
const generateReferralLink = (referralCode, baseUrl = 'https://yourapp.com') => {
  return `${baseUrl}/register?ref=${referralCode}`;
};

/**
 * Generate share text for social media
 * @param {string} referralCode - User's referral code
 * @param {string} appName - Name of the application
 * @returns {string} - Shareable text
 */
const generateShareText = (referralCode, appName = '5-in-1 Earning System') => {
  return `Join me on ${appName} and earn coins together! Use my referral code: ${referralCode} 🎉💰`;
};

/**
 * Parse referral data from URL
 * @param {string} url - URL to parse
 * @returns {string|null} - Referral code if found
 */
const parseReferralFromUrl = (url) => {
  try {
    const urlObj = new URL(url);
    return urlObj.searchParams.get('ref') || null;
  } catch (error) {
    return null;
  }
};

module.exports = {
  generateReferralCode,
  generateMultipleReferralCodes,
  validateReferralCodeFormat,
  calculateReferrerBonus,
  calculateReferredUserBonus,
  generateReferralLink,
  generateShareText,
  parseReferralFromUrl
};

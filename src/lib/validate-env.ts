// Environment Variable Validation
// Run this to check if all required environment variables are set

export function validateEnvironment(): {
  isValid: boolean;
  errors: string[];
  warnings: string[];
} {
  const errors: string[] = [];
  const warnings: string[] = [];

  // Required variables
  const requiredVars = {
    NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
    NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
  };

  // Optional but recommended variables
  const optionalVars = {
    NEXT_PUBLIC_GA_MEASUREMENT_ID: process.env.NEXT_PUBLIC_GA_MEASUREMENT_ID,
    NODE_ENV: process.env.NODE_ENV,
  };

  // Check required variables
  Object.entries(requiredVars).forEach(([key, value]) => {
    if (!value) {
      errors.push(`❌ Missing required environment variable: ${key}`);
    } else if (value.includes('your-') || value.includes('example')) {
      errors.push(`❌ ${key} contains placeholder value. Please update with actual credentials.`);
    }
  });

  // Check optional variables
  Object.entries(optionalVars).forEach(([key, value]) => {
    if (!value) {
      warnings.push(`⚠️  Optional environment variable not set: ${key}`);
    }
  });

  // Validate Supabase URL format
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  if (supabaseUrl && !supabaseUrl.startsWith('https://')) {
    errors.push('❌ NEXT_PUBLIC_SUPABASE_URL must start with https://');
  }

  // Validate Supabase URL contains supabase.co
  if (supabaseUrl && !supabaseUrl.includes('supabase.co')) {
    warnings.push('⚠️  NEXT_PUBLIC_SUPABASE_URL should contain supabase.co');
  }

  return {
    isValid: errors.length === 0,
    errors,
    warnings,
  };
}

export function printValidation() {
  const { isValid, errors, warnings } = validateEnvironment();

  console.log('\n🔍 Environment Validation\n');
  console.log('─'.repeat(50));

  if (errors.length > 0) {
    console.log('\n❌ ERRORS:');
    errors.forEach(error => console.log(error));
  }

  if (warnings.length > 0) {
    console.log('\n⚠️  WARNINGS:');
    warnings.forEach(warning => console.log(warning));
  }

  if (isValid && warnings.length === 0) {
    console.log('\n✅ All environment variables are properly configured!');
  } else if (isValid) {
    console.log('\n✅ Required variables are set (warnings can be ignored)');
  } else {
    console.log('\n❌ Please fix the errors above before continuing.');
    console.log('\n📖 See SETUP-GUIDE.md for help');
  }

  console.log('\n' + '─'.repeat(50) + '\n');

  return isValid;
}

// Auto-run validation in development
if (process.env.NODE_ENV === 'development') {
  if (typeof window === 'undefined') {
    // Server-side
    printValidation();
  }
}

export default validateEnvironment;


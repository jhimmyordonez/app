<script setup>
import { ref } from 'vue';

const username = ref('');
const password = ref('');
const isLoading = ref(false);
const showPassword = ref(false);
const errorMessage = ref('');

const emit = defineEmits(['login-success']);

const handleLogin = () => {
  isLoading.value = true;
  
  // Fast Sign In UX: Immediate feedback and transition
  setTimeout(() => {
    isLoading.value = false;
    emit('login-success');
  }, 600);
};

const togglePassword = () => {
  showPassword.value = !showPassword.value;
};
</script>

<template>
  <div class="login-container">
    <div class="login-card">
      <!-- Decorative elements -->
      <div class="card-glow"></div>
      
      <!-- Logo -->
      <div class="logo-container">
        <div class="logo-icon">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 3c1.66 0 3 1.34 3 3s-1.34 3-3 3-3-1.34-3-3 1.34-3 3-3zm0 14.2c-2.5 0-4.71-1.28-6-3.22.03-1.99 4-3.08 6-3.08 1.99 0 5.97 1.09 6 3.08-1.29 1.94-3.5 3.22-6 3.22z"/>
          </svg>
        </div>
      </div>

      <!-- Form -->
      <form @submit.prevent="handleLogin" class="login-form">
        <!-- Error message -->
        <div v-if="errorMessage" class="error-message">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/>
          </svg>
          <span>{{ errorMessage }}</span>
        </div>

        <!-- Username field -->
        <div class="input-group">
          <label for="username" class="input-label">Username</label>
          <div class="input-wrapper">
            <input
              id="username"
              v-model="username"
              type="text"
              placeholder="Enter your username"
              class="input-field"
              autocomplete="username"
            />
          </div>
        </div>

        <!-- Password field -->
        <div class="input-group">
          <label for="password" class="input-label">Password</label>
          <div class="input-wrapper">
            <input
              id="password"
              v-model="password"
              :type="showPassword ? 'text' : 'password'"
              placeholder="Enter your password"
              class="input-field"
              autocomplete="current-password"
            />
            <button type="button" class="toggle-password" @click="togglePassword">
              <svg v-if="!showPassword" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/>
              </svg>
              <svg v-else xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 7c2.76 0 5 2.24 5 5 0 .65-.13 1.26-.36 1.83l2.92 2.92c1.51-1.26 2.7-2.89 3.43-4.75-1.73-4.39-6-7.5-11-7.5-1.4 0-2.74.25-3.98.7l2.16 2.16C10.74 7.13 11.35 7 12 7zM2 4.27l2.28 2.28.46.46C3.08 8.3 1.78 10.02 1 12c1.73 4.39 6 7.5 11 7.5 1.55 0 3.03-.3 4.38-.84l.42.42L19.73 22 21 20.73 3.27 3 2 4.27zM7.53 9.8l1.55 1.55c-.05.21-.08.43-.08.65 0 1.66 1.34 3 3 .22 0 .44-.03.65-.08l1.55 1.55c-.67.33-1.41.53-2.2.53-2.76 0-5-2.24-5-5 0-.79.2-1.53.53-2.2zm4.31-.78l3.15 3.15.02-.16c0-1.66-1.34-3-3-3l-.17.01z"/>
              </svg>
            </button>
          </div>
        </div>

        <!-- Submit button -->
        <button 
          type="submit" 
          class="submit-btn"
          :disabled="isLoading"
        >
          <span v-if="isLoading" class="spinner"></span>
          <span v-else>Sign In</span>
        </button>
      </form>

      <!-- Footer -->
      <div class="login-footer">
        <a href="#" class="forgot-link">Forgot your password?</a>
      </div>
    </div>
  </div>
</template>

<style scoped>
.login-container {
  min-height: 100vh;
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: var(--bg-secondary);
  padding: 20px;
  position: relative;
  overflow: hidden;
}



.login-card {
  position: relative;
  width: 100%;
  max-width: 360px;
  background: var(--bg-primary);
  border-radius: 8px;
  padding: 40px 32px;
  border: 1px solid var(--bg-tertiary);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
}



.logo-container {
  text-align: center;
  margin-bottom: 28px;
}

.logo-icon {
  width: 64px;
  height: 64px;
  margin: 0 auto;
  background: var(--accent-blue);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.logo-icon svg {
  width: 40px;
  height: 40px;
  color: white;
}



.login-form {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.error-message {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 14px 16px;
  background: rgba(239, 68, 68, 0.15);
  border: 1px solid rgba(239, 68, 68, 0.3);
  border-radius: 6px;
  color: #fca5a5;
  font-size: 0.875rem;
}

.error-message svg {
  width: 20px;
  height: 20px;
  flex-shrink: 0;
}

.input-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.input-label {
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--text-primary);
}

.input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.input-field {
  width: 100%;
  padding: 12px 16px;
  background: var(--bg-secondary);
  border: 1px solid var(--bg-tertiary);
  border-radius: 4px;
  font-size: 0.95rem;
  color: var(--text-primary);
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
  outline: none;
}

.input-field::placeholder {
  color: rgba(255, 255, 255, 0.3);
}

.input-field:hover {
  border-color: rgba(255, 255, 255, 0.2);
}

.input-field:focus {
  border-color: var(--accent-blue);
  box-shadow: 0 0 0 2px rgba(97, 175, 239, 0.2);
}

.toggle-password {
  position: absolute;
  right: 12px;
  background: none;
  border: none;
  padding: 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  transition: background-color 0.2s ease;
}

.toggle-password:hover {
  background: rgba(255, 255, 255, 0.1);
}

.toggle-password svg {
  width: 20px;
  height: 20px;
  color: rgba(255, 255, 255, 0.4);
  transition: color 0.2s ease;
}

.toggle-password:hover svg {
  color: rgba(255, 255, 255, 0.7);
}

.submit-btn {
  width: 100%;
  padding: 12px 24px;
  background: var(--accent-blue);
  border: none;
  border-radius: 4px;
  font-size: 1rem;
  font-weight: 600;
  color: var(--bg-primary);
  cursor: pointer;
  transition: background-color 0.2s ease;
  margin-top: 8px;
}

.submit-btn:hover:not(:disabled) {
  background: #72bef6;
}

.submit-btn:disabled {
  cursor: not-allowed;
  opacity: 0.7;
}

.spinner {
  display: inline-block;
  width: 20px;
  height: 20px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.login-footer {
  margin-top: 28px;
  text-align: center;
}

.forgot-link {
  font-size: 0.875rem;
  color: var(--text-secondary);
  text-decoration: none;
  transition: color 0.2s ease;
}

.forgot-link:hover {
  color: var(--accent-blue);
}

/* Responsive */
@media (max-width: 480px) {
  .login-card {
    padding: 32px 24px;
  }
  
  .login-title {
    font-size: 1.5rem;
  }
  
  .logo-icon {
    width: 60px;
    height: 60px;
    border-radius: 16px;
  }
  
  .logo-icon svg {
    width: 32px;
    height: 32px;
  }
}
</style>

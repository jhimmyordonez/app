<script setup>
import { ref } from 'vue';
import Sidebar from './Sidebar.vue';

const emit = defineEmits(['logout']);
const currentView = ref('menu');

// Component state
const newCategory = ref('');
const wordSpanish = ref('');
const wordEnglish = ref('');
const selectedCategory = ref('');
const practiceAnswer = ref('');
const categories = ref(['General', 'Technology', 'Business']);

// Practice setup state
const generatedWords = ref('');
const exercisesJson = ref('');

// Sample words for generation
const sampleWords = [
  'casa', 'perro', 'gato', 'libro', 'mesa', 'silla', 'agua', 'comida',
  'amigo', 'familia', 'trabajo', 'escuela', 'ciudad', 'país', 'tiempo',
  'día', 'noche', 'sol', 'luna', 'mar', 'montaña', 'río', 'árbol', 'flor',
  'calle', 'carro', 'puerta', 'ventana', 'cocina', 'baño'
];

const generateRandomWords = () => {
  const shuffled = [...sampleWords].sort(() => Math.random() - 0.5);
  const selected = shuffled.slice(0, 20);
  generatedWords.value = selected.join('\n');
};

const goToMenu = () => {
  currentView.value = 'menu';
};

const handleAddCategory = () => {
  if (newCategory.value.trim()) {
    categories.value.push(newCategory.value.trim());
    newCategory.value = '';
    goToMenu();
  }
};

const handleAddWord = () => {
  // Placeholder for word addition logic
  wordSpanish.value = '';
  wordEnglish.value = '';
  selectedCategory.value = '';
};
</script>

<template>
  <div class="dashboard-layout">
    <Sidebar @logout="emit('logout')" />
    
    <main class="main-content">
      <!-- Main Menu View -->
      <div v-if="currentView === 'menu'" class="view-container centered">
        <div class="menu-card">
          <button class="menu-item" @click="currentView = 'add-category'">
            Add Category
          </button>
          <button class="menu-item" @click="currentView = 'add-word'">
            Add Word
          </button>
          <button class="menu-item" @click="currentView = 'practice-setup'">
            Practice
          </button>
        </div>
      </div>

      <!-- Add Category View -->
      <div v-if="currentView === 'add-category'" class="view-container centered">
        <div class="content-wrapper">
          <h1 class="view-title">Add Category</h1>
          <div class="form-card">
            <div class="input-group">
              <label class="input-label">Write a category</label>
              <input 
                v-model="newCategory" 
                type="text" 
                placeholder="e.g. Travel"
                class="dashboard-input"
              />
            </div>
            <div class="btn-group">
              <button class="dashboard-btn secondary" @click="goToMenu">Back</button>
              <button class="dashboard-btn" @click="handleAddCategory">Create</button>
            </div>
          </div>
        </div>
      </div>

      <!-- Add Word View -->
      <div v-if="currentView === 'add-word'" class="view-container centered">
        <div class="content-wrapper">
          <h1 class="view-title">Add Word</h1>
          <div class="form-card">
            <div class="input-group">
              <label class="input-label">Select Category</label>
              <select v-model="selectedCategory" class="dashboard-input">
                <option disabled value="">Choose a category</option>
                <option v-for="cat in categories" :key="cat" :value="cat">{{ cat }}</option>
              </select>
            </div>
            <div class="input-group">
              <label class="input-label">Spanish</label>
              <input v-model="wordSpanish" type="text" class="dashboard-input" placeholder="Word in Spanish" />
            </div>
            <div class="input-group">
              <label class="input-label">English</label>
              <input v-model="wordEnglish" type="text" class="dashboard-input" placeholder="Word in English" />
            </div>
            <div class="btn-group">
              <button class="dashboard-btn secondary" @click="goToMenu">Back</button>
              <button class="dashboard-btn" @click="handleAddWord">Add Word</button>
            </div>
          </div>
        </div>
      </div>

      <!-- Practice Setup View -->
      <div v-if="currentView === 'practice-setup'" class="view-container centered">
        <div class="content-wrapper wide">
          <div class="form-card">
            <button class="dashboard-btn full-width" @click="generateRandomWords">
              Generar 20 palabras random
            </button>
            
            <div class="input-group mt-20">
              <textarea 
                v-model="generatedWords" 
                class="dashboard-textarea"
                placeholder="Se genera 20 palabras random en json"
                rows="6"
                readonly
              ></textarea>
            </div>
            
            <div class="input-group">
              <textarea 
                v-model="exercisesJson" 
                class="dashboard-textarea"
                placeholder="Acá se pega los ejercicios generados con esas palabras"
                rows="6"
              ></textarea>
            </div>
            
            <div class="btn-group">
              <button class="dashboard-btn secondary" @click="goToMenu">Back</button>
              <button class="dashboard-btn" @click="currentView = 'practice'">
                Ir a Practice
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Practice View -->
      <div v-if="currentView === 'practice'" class="view-container centered">
        <div class="content-wrapper">
          <h1 class="view-title">Practice</h1>
          <div class="practice-card">
            <p class="practice-sentence">Oración para completar con palabra random ______</p>
            <div class="options-grid">
              <button class="option-btn">Option 1</button>
              <button class="option-btn">Option 2</button>
              <button class="option-btn">Option 3</button>
            </div>
            <div class="write-section">
              <input 
                v-model="practiceAnswer" 
                type="text" 
                placeholder="Escribir acá" 
                class="dashboard-input"
              />
            </div>
            <div class="btn-group">
              <button class="dashboard-btn secondary" @click="goToMenu">Back</button>
              <button class="dashboard-btn">Check</button>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<style scoped>
.dashboard-layout {
  display: flex;
  width: 100%;
  height: 100vh;
  background-color: var(--bg-primary);
}

.main-content {
  flex: 1;
  overflow-y: auto;
  padding: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.view-container {
  width: 100%;
  max-width: 600px;
}

.view-container.centered {
  display: flex;
  justify-content: center;
  align-items: center;
}

.content-wrapper {
  width: 100%;
}

.view-title {
  font-size: 1.5rem;
  margin-bottom: 24px;
  color: var(--text-primary);
  text-align: center;
}

/* Menu Card */
.menu-card {
  background-color: var(--bg-secondary);
  padding: 40px;
  border-radius: 12px;
  border: 1px solid var(--bg-tertiary);
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-width: 300px;
}

.menu-item {
  padding: 16px 24px;
  background: none;
  border: 1px solid var(--bg-tertiary);
  border-radius: 8px;
  color: var(--text-primary);
  font-size: 1rem;
  cursor: pointer;
  transition: background-color 0.2s ease, border-color 0.2s ease;
}

.menu-item:hover {
  background-color: var(--bg-tertiary);
  border-color: var(--accent-blue);
}

/* Form Card */
.form-card {
  background-color: var(--bg-secondary);
  padding: 32px;
  border-radius: 12px;
  border: 1px solid var(--bg-tertiary);
}

.input-group {
  margin-bottom: 20px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.input-label {
  font-size: 0.9rem;
  color: var(--text-primary);
}

.dashboard-input {
  padding: 12px;
  background-color: var(--bg-primary);
  border: 1px solid var(--bg-tertiary);
  border-radius: 6px;
  color: var(--text-primary);
  outline: none;
  font-size: 0.95rem;
}

.dashboard-input:focus {
  border-color: var(--accent-blue);
}

.btn-group {
  display: flex;
  gap: 12px;
  margin-top: 24px;
}

.dashboard-btn {
  flex: 1;
  padding: 12px;
  background-color: var(--accent-blue);
  color: var(--bg-primary);
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s ease;
}

.dashboard-btn:hover {
  background-color: #72bef6;
}

.dashboard-btn.secondary {
  background-color: transparent;
  border: 1px solid var(--bg-tertiary);
  color: var(--text-primary);
}

.dashboard-btn.secondary:hover {
  background-color: var(--bg-tertiary);
}

/* Practice Card */
.practice-card {
  background-color: var(--bg-secondary);
  padding: 32px;
  border-radius: 12px;
  border: 1px solid var(--bg-tertiary);
}

.practice-sentence {
  font-size: 1.1rem;
  margin-bottom: 24px;
  text-align: center;
  color: var(--text-primary);
}

.options-grid {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 20px;
}

.option-btn {
  padding: 12px;
  background: none;
  border: 1px solid var(--bg-tertiary);
  border-radius: 6px;
  color: var(--text-primary);
  cursor: pointer;
  transition: background-color 0.2s ease, border-color 0.2s ease;
}

.option-btn:hover {
  background-color: var(--bg-tertiary);
  border-color: var(--accent-blue);
}

.write-section {
  margin-bottom: 8px;
}

/* Practice Setup */
.content-wrapper.wide {
  max-width: 500px;
}

.dashboard-textarea {
  width: 100%;
  padding: 12px;
  background-color: var(--bg-primary);
  border: 1px solid var(--bg-tertiary);
  border-radius: 6px;
  color: var(--text-primary);
  outline: none;
  font-size: 0.95rem;
  font-family: inherit;
  resize: vertical;
  min-height: 100px;
}

.dashboard-textarea:focus {
  border-color: var(--accent-blue);
}

.dashboard-textarea::placeholder {
  color: var(--text-secondary);
  opacity: 0.6;
}

.dashboard-btn.full-width {
  width: 100%;
  flex: none;
}

.mt-20 {
  margin-top: 20px;
}
</style>

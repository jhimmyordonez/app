<script setup>
import { ref, onMounted, watch } from 'vue';
import Sidebar from './Sidebar.vue';

const API_URL = 'http://localhost:3000/api';

const emit = defineEmits(['logout']);
const currentView = ref('menu');

// Component state
const newCategory = ref('');
const wordSpanish = ref('');
const wordEnglish = ref('');
const selectedCategory = ref('');
const practiceAnswer = ref('');
const categories = ref([]);
const isLoading = ref(false);
const errorMsg = ref('');

// Words by category state
const categoryWords = ref([]);
const isLoadingWords = ref(false);

// Practice setup state
const generatedWords = ref('');
const exercisesJson = ref('');
const exercises = ref([]);
const currentExerciseIndex = ref(0);
const selectedOption = ref('');
const showResult = ref(false);
const isCorrect = ref(false);
const score = ref({ correct: 0, total: 0 });
const copiedJson = ref(false);
const failedExercises = ref([]);

// Fetch categories on mount
onMounted(async () => {
  await fetchCategories();
});

const fetchCategories = async () => {
  try {
    const res = await fetch(`${API_URL}/categories`);
    const data = await res.json();
    console.log('Categories loaded:', data);
    categories.value = data;
  } catch (error) {
    console.error('Error fetching categories:', error);
  }
};

const generateRandomWords = async () => {
  isLoading.value = true;
  try {
    const res = await fetch(`${API_URL}/words/random`);
    const words = await res.json();
    generatedWords.value = words.map(w => `${w.spanish} - ${w.english}`).join('\n');
  } catch (error) {
    errorMsg.value = 'Error generating words';
  } finally {
    isLoading.value = false;
  }
};

const goToMenu = () => {
  currentView.value = 'menu';
  resetPractice();
};

const goToAddCategory = async () => {
  await fetchCategories();
  currentView.value = 'add-category';
};

const goToAddWord = async () => {
  await fetchCategories();
  selectedCategory.value = '';
  categoryWords.value = [];
  currentView.value = 'add-word';
};

// Fetch words by category
const fetchWordsByCategory = async (categoryId) => {
  if (!categoryId) {
    categoryWords.value = [];
    return;
  }
  isLoadingWords.value = true;
  try {
    const res = await fetch(`${API_URL}/words?category_id=${categoryId}`);
    const words = await res.json();
    categoryWords.value = words;
  } catch (error) {
    console.error('Error fetching words:', error);
    categoryWords.value = [];
  } finally {
    isLoadingWords.value = false;
  }
};

// Watch for category selection changes
watch(selectedCategory, (newVal) => {
  fetchWordsByCategory(newVal);
});

const resetPractice = () => {
  exercises.value = [];
  currentExerciseIndex.value = 0;
  selectedOption.value = '';
  showResult.value = false;
  score.value = { correct: 0, total: 0 };
  failedExercises.value = [];
  exercisesJson.value = '';
  generatedWords.value = '';
};

const handleAddCategory = async () => {
  if (!newCategory.value.trim()) return;
  isLoading.value = true;
  try {
    const res = await fetch(`${API_URL}/categories`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: newCategory.value.trim() })
    });
    if (res.ok) {
      await fetchCategories();
      newCategory.value = '';
      goToMenu();
    }
  } catch (error) {
    errorMsg.value = 'Error creating category';
  } finally {
    isLoading.value = false;
  }
};

const handleAddWord = async () => {
  if (!wordSpanish.value.trim() || !wordEnglish.value.trim() || !selectedCategory.value) return;
  isLoading.value = true;
  try {
    const res = await fetch(`${API_URL}/words`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        spanish: wordSpanish.value.trim(),
        english: wordEnglish.value.trim(),
        category_id: selectedCategory.value
      })
    });
    if (res.ok) {
      wordSpanish.value = '';
      wordEnglish.value = '';
      selectedCategory.value = '';
      goToMenu();
    }
  } catch (error) {
    errorMsg.value = 'Error adding word';
  } finally {
    isLoading.value = false;
  }
};

const startPractice = async () => {
  try {
    const parsed = JSON.parse(exercisesJson.value);
    if (Array.isArray(parsed) && parsed.length > 0) {
      // Save to backend
      await fetch(`${API_URL}/exercises`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ exercises: parsed })
      });
      
      exercises.value = parsed;
      currentExerciseIndex.value = 0;
      score.value = { correct: 0, total: 0 };
      currentView.value = 'practice';
    } else {
      errorMsg.value = 'JSON inválido. Debe ser un array de ejercicios.';
    }
  } catch (error) {
    errorMsg.value = 'Error parsing JSON: ' + error.message;
  }
};

const currentExercise = () => exercises.value[currentExerciseIndex.value] || null;

const selectOption = (option) => {
  if (showResult.value) return;
  selectedOption.value = option;
  const exercise = currentExercise();
  isCorrect.value = option === exercise.answer;
  score.value.total++;
  if (isCorrect.value) {
    score.value.correct++;
  } else {
    // Save failed exercise to retry later
    failedExercises.value.push(exercise);
  }
  showResult.value = true;
};

// Retry failed exercises
const retryFailedExercises = () => {
  if (failedExercises.value.length === 0) return;
  exercises.value = [...failedExercises.value];
  failedExercises.value = [];
  currentExerciseIndex.value = 0;
  selectedOption.value = '';
  showResult.value = false;
  score.value = { correct: 0, total: 0 };
  currentView.value = 'practice';
};

const nextExercise = () => {
  if (currentExerciseIndex.value < exercises.value.length - 1) {
    currentExerciseIndex.value++;
    selectedOption.value = '';
    showResult.value = false;
  } else {
    currentView.value = 'results';
  }
};

const submitWrittenAnswer = () => {
  if (!practiceAnswer.value.trim()) return;
  const exercise = currentExercise();
  isCorrect.value = practiceAnswer.value.trim().toLowerCase() === exercise.answer.toLowerCase();
  score.value.total++;
  if (isCorrect.value) score.value.correct++;
  showResult.value = true;
  practiceAnswer.value = '';
};

const exampleJson = `[
  {
    "sentence": "I need to ____ the document before sending.",
    "answer": "revise",
    "options": ["revise", "delete", "ignore"]
  },
  {
    "sentence": "The project was a complete ____.",
    "answer": "success",
    "options": ["success", "failure", "disaster"]
  }
]`;

const copyExampleJson = async () => {
  try {
    await navigator.clipboard.writeText(exampleJson);
    copiedJson.value = true;
    setTimeout(() => copiedJson.value = false, 2000);
  } catch (err) {
    console.error('Failed to copy:', err);
  }
};
</script>

<template>
  <div class="dashboard-layout">
    <Sidebar @logout="emit('logout')" />
    
    <main class="main-content">
      <!-- Main Menu View -->
      <div v-if="currentView === 'menu'" class="view-container centered">
        <div class="menu-card">
          <button class="menu-item" @click="goToAddCategory">
            Add Category
          </button>
          <button class="menu-item" @click="goToAddWord">
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
            
            <!-- Existing Categories List -->
            <div v-if="categories.length > 0" class="categories-list-section">
              <h3 class="section-subtitle">Existing Categories</h3>
              <ul class="categories-list">
                <li v-for="cat in categories" :key="cat.id" class="category-item">
                  {{ cat.name }}
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>

      <!-- Add Word View -->
      <div v-if="currentView === 'add-word'" class="view-container add-word-view">
        <div class="add-word-header">
          <button class="back-btn" @click="goToMenu">
            ← Back
          </button>
          <h1 class="add-word-title">Add New Word</h1>
        </div>
        
        <div class="add-word-content">
          <!-- Form Section -->
          <div class="add-word-form-section">
            <div class="section-header">
              <h2 class="section-title">New Word</h2>
            </div>
            <div class="form-card">
              <div class="input-group">
                <label class="input-label">Category</label>
                <select v-model="selectedCategory" class="dashboard-input">
                  <option disabled value="">Select a category</option>
                  <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
                </select>
              </div>
              <div class="input-row">
                <div class="input-group">
                  <label class="input-label">Spanish</label>
                  <input v-model="wordSpanish" type="text" class="dashboard-input" placeholder="Word in Spanish" />
                </div>
                <div class="input-group">
                  <label class="input-label">English</label>
                  <input v-model="wordEnglish" type="text" class="dashboard-input" placeholder="Word in English" />
                </div>
              </div>
              <button class="dashboard-btn add-word-btn" @click="handleAddWord" :disabled="!selectedCategory || !wordSpanish || !wordEnglish">
                + Add Word
              </button>
            </div>
          </div>
          
          <!-- Words Preview Panel -->
          <div class="add-word-preview-section">
            <div class="section-header">
              <h2 class="section-title">Words in Category</h2>
              <span v-if="selectedCategory && categoryWords.length > 0" class="words-count">
                {{ categoryWords.length }} words
              </span>
            </div>
            <div class="words-preview-panel">
              <div v-if="isLoadingWords" class="loading-state">
                <span class="loading-spinner"></span>
                <span>Loading words...</span>
              </div>
              <div v-else-if="!selectedCategory" class="empty-state">
                <p>Select a category to see its words</p>
              </div>
              <div v-else-if="categoryWords.length === 0" class="empty-state">
                <p>No words in this category</p>
                <span class="empty-hint">Add the first one!</span>
              </div>
              <ul v-else class="words-list">
                <li v-for="word in categoryWords" :key="word.id" class="word-item">
                  <span class="word-spanish">{{ word.spanish }}</span>
                  <span class="word-separator">→</span>
                  <span class="word-english">{{ word.english }}</span>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>

      <!-- Practice Setup View -->
      <div v-if="currentView === 'practice-setup'" class="view-container centered">
        <div class="content-wrapper wide">
          <div class="form-card">
            <button class="dashboard-btn full-width" @click="generateRandomWords">
              Generate 20 Random Words
            </button>
            
            
            <div class="input-group mt-20">
              <textarea 
                v-model="generatedWords" 
                class="dashboard-textarea"
                placeholder="20 random words will be generated here"
                rows="6"
                readonly
              ></textarea>
            </div>
            
            <div class="input-group">
              <textarea 
                v-model="exercisesJson" 
                class="dashboard-textarea"
                placeholder="Paste exercises JSON here"
                rows="6"
              ></textarea>
            </div>
            
            <div class="example-json">
              <div class="example-header">
                <span class="example-label">Example JSON (click to copy):</span>
              </div>
              <pre class="example-code" @click="copyExampleJson">[
  {
    "sentence": "I need to ____ the document before sending.",
    "answer": "revise",
    "options": ["revise", "delete", "ignore"]
  },
  {
    "sentence": "The project was a complete ____.",
    "answer": "success",
    "options": ["success", "failure", "disaster"]
  }
]</pre>
              <span v-if="copiedJson" class="copied-msg">✓ Copied!</span>
            </div>
            
            <div class="btn-group">
              <button class="dashboard-btn secondary" @click="goToMenu">Back</button>
              <button class="dashboard-btn" @click="startPractice" :disabled="!exercisesJson">
                Start Practice
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Practice View -->
      <div v-if="currentView === 'practice' && currentExercise()" class="view-container centered">
        <div class="content-wrapper">
          <div class="practice-header">
            <span class="progress-text">{{ currentExerciseIndex + 1 }} / {{ exercises.length }}</span>
            <span class="score-text">✓ {{ score.correct }}</span>
          </div>
          <div class="practice-card">
            <p class="practice-sentence">{{ currentExercise().sentence }}</p>
            <div class="options-grid">
              <button 
                v-for="(option, idx) in currentExercise().options" 
                :key="idx"
                class="option-btn"
                :class="{
                  'correct': showResult && option === currentExercise().answer,
                  'incorrect': showResult && selectedOption === option && option !== currentExercise().answer,
                  'selected': selectedOption === option
                }"
                @click="selectOption(option)"
                :disabled="showResult"
              >
                {{ option }}
              </button>
            </div>
            <div v-if="showResult" class="result-feedback" :class="isCorrect ? 'correct' : 'incorrect'">
              {{ isCorrect ? 'Correct!' : `Incorrect. The answer was: ${currentExercise().answer}` }}
            </div>
            <div class="btn-group">
              <button class="dashboard-btn secondary" @click="goToMenu">Exit</button>
              <button v-if="showResult" class="dashboard-btn" @click="nextExercise">
                {{ currentExerciseIndex < exercises.length - 1 ? 'Next' : 'Finish' }}
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Results View -->
      <div v-if="currentView === 'results'" class="view-container centered">
        <div class="content-wrapper">
          <div class="results-card">
            <h1 class="results-title">Completed!</h1>
            <div class="results-score">
              <span class="score-number">{{ score.correct }}</span>
              <span class="score-divider">/</span>
              <span class="score-total">{{ score.total }}</span>
            </div>
            <p class="results-percentage">{{ Math.round((score.correct / score.total) * 100) }}% correct</p>
            
            <!-- Failed exercises info -->
            <div v-if="failedExercises.length > 0" class="failed-info">
              <p class="failed-count">{{ failedExercises.length }} failed exercise(s)</p>
              <button class="dashboard-btn retry-btn" @click="retryFailedExercises">
                Retry Failed
              </button>
            </div>
            
            <button class="dashboard-btn" @click="goToMenu">Back to Menu</button>
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

/* Practice Header */
.practice-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 16px;
  font-size: 0.9rem;
}

.progress-text {
  color: var(--text-secondary);
}

.score-text {
  color: #4ade80;
  font-weight: 600;
}

/* Option States */
.option-btn.correct {
  background-color: rgba(74, 222, 128, 0.2);
  border-color: #4ade80;
  color: #4ade80;
}

.option-btn.incorrect {
  background-color: rgba(248, 113, 113, 0.2);
  border-color: #f87171;
  color: #f87171;
}

.option-btn.selected {
  border-color: var(--accent-blue);
}

.option-btn:disabled {
  cursor: not-allowed;
  opacity: 0.8;
}

/* Result Feedback */
.result-feedback {
  padding: 12px;
  border-radius: 6px;
  text-align: center;
  margin: 16px 0;
  font-weight: 500;
}

.result-feedback.correct {
  background-color: rgba(74, 222, 128, 0.15);
  color: #4ade80;
}

.result-feedback.incorrect {
  background-color: rgba(248, 113, 113, 0.15);
  color: #f87171;
}

/* Results View */
.results-card {
  background-color: var(--bg-secondary);
  padding: 48px 32px;
  border-radius: 12px;
  border: 1px solid var(--bg-tertiary);
  text-align: center;
}

.results-title {
  font-size: 2rem;
  margin-bottom: 24px;
  color: var(--text-primary);
}

.results-score {
  font-size: 3rem;
  margin-bottom: 8px;
}

.score-number {
  color: #4ade80;
  font-weight: 700;
}

.score-divider {
  color: var(--text-secondary);
  margin: 0 8px;
}

.score-total {
  color: var(--text-primary);
}

.results-percentage {
  color: var(--text-secondary);
  margin-bottom: 32px;
  font-size: 1.1rem;
}

/* Example JSON */
.example-json {
  margin-top: 16px;
  position: relative;
}

.example-header {
  margin-bottom: 8px;
}

.example-label {
  font-size: 0.85rem;
  color: var(--text-secondary);
}

.example-code {
  background-color: var(--bg-primary);
  border: 1px solid var(--bg-tertiary);
  border-radius: 6px;
  padding: 12px;
  font-size: 0.8rem;
  color: var(--text-primary);
  overflow-x: auto;
  cursor: pointer;
  transition: border-color 0.2s ease;
  margin: 0;
  white-space: pre;
}

.example-code:hover {
  border-color: var(--accent-blue);
}

.copied-msg {
  position: absolute;
  top: 0;
  right: 0;
  font-size: 0.8rem;
  color: #4ade80;
  font-weight: 500;
}

/* Categories List Section */
.categories-list-section {
  margin-top: 24px;
  padding-top: 20px;
  border-top: 1px solid var(--bg-tertiary);
}

.section-subtitle {
  font-size: 0.95rem;
  color: var(--text-secondary);
  margin-bottom: 12px;
  font-weight: 500;
}

.categories-list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.category-item {
  padding: 8px 16px;
  background-color: var(--bg-primary);
  border: 1px solid var(--bg-tertiary);
  border-radius: 20px;
  font-size: 0.9rem;
  color: var(--text-primary);
}

/* Add Word Full Screen Layout */
.add-word-view {
  display: flex;
  flex-direction: column;
  height: 100%;
  max-width: none !important;
  padding: 0;
}

.add-word-header {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 24px 32px;
  border-bottom: 1px solid var(--bg-tertiary);
  background-color: var(--bg-secondary);
}

.back-btn {
  padding: 10px 16px;
  background: none;
  border: 1px solid var(--bg-tertiary);
  border-radius: 8px;
  color: var(--text-primary);
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 0.9rem;
}

.back-btn:hover {
  background-color: var(--bg-tertiary);
  border-color: var(--accent-blue);
}

.add-word-title {
  font-size: 1.5rem;
  color: var(--text-primary);
  margin: 0;
  font-weight: 600;
}

.add-word-content {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 32px;
  padding: 32px;
  flex: 1;
  overflow: hidden;
}

@media (max-width: 1000px) {
  .add-word-content {
    grid-template-columns: 1fr;
    overflow-y: auto;
  }
}

.add-word-form-section,
.add-word-preview-section {
  display: flex;
  flex-direction: column;
  min-height: 0;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.section-icon {
  font-size: 1.3rem;
}

.section-title {
  font-size: 1.1rem;
  color: var(--text-primary);
  margin: 0;
  font-weight: 600;
}

.words-count {
  margin-left: auto;
  padding: 4px 12px;
  background-color: var(--accent-blue);
  color: var(--bg-primary);
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
}

.add-word-form-section .form-card {
  flex: 0 0 auto;
}

.input-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

@media (max-width: 600px) {
  .input-row {
    grid-template-columns: 1fr;
  }
}

.add-word-btn {
  width: 100%;
  margin-top: 8px;
  padding: 14px;
  font-size: 1rem;
}

.add-word-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Words Preview Panel - Updated */
.add-word-preview-section .words-preview-panel {
  flex: 1;
  min-height: 0;
  max-height: none;
  overflow-y: auto;
}

.words-preview-panel {
  background-color: var(--bg-secondary);
  padding: 24px;
  border-radius: 12px;
  border: 1px solid var(--bg-tertiary);
  max-height: 500px;
  min-height: 300px;
  overflow-y: auto;
}

.loading-state {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 60px 20px;
  color: var(--text-secondary);
}

.loading-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid var(--bg-tertiary);
  border-top-color: var(--accent-blue);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  text-align: center;
}

.empty-icon {
  font-size: 3rem;
  margin-bottom: 16px;
  opacity: 0.8;
}

.empty-state p {
  color: var(--text-secondary);
  font-size: 1rem;
  margin: 0;
}

.empty-hint {
  color: var(--accent-blue);
  font-size: 0.9rem;
  margin-top: 8px;
}

.panel-title {
  font-size: 1.1rem;
  color: var(--text-primary);
  margin-bottom: 20px;
  font-weight: 600;
  padding-bottom: 12px;
  border-bottom: 1px solid var(--bg-tertiary);
}

.loading-text,
.empty-text {
  color: var(--text-secondary);
  font-size: 0.9rem;
  text-align: center;
  padding: 40px 20px;
}

.words-list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.word-item {
  padding: 14px 16px;
  background-color: var(--bg-primary);
  border: 1px solid var(--bg-tertiary);
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 0.95rem;
  transition: border-color 0.2s ease;
}

.word-item:hover {
  border-color: var(--accent-blue);
}

.word-spanish {
  color: var(--accent-blue);
  font-weight: 500;
}

.word-separator {
  color: var(--text-secondary);
}

.word-english {
  color: var(--text-primary);
}

/* Failed Exercises Section */
.failed-info {
  margin: 20px 0;
  padding: 16px;
  background-color: rgba(248, 113, 113, 0.1);
  border: 1px solid rgba(248, 113, 113, 0.3);
  border-radius: 8px;
}

.failed-count {
  color: #f87171;
  font-size: 0.95rem;
  margin-bottom: 12px;
}

.retry-btn {
  background-color: #f87171 !important;
  width: 100%;
  margin-bottom: 0;
}

.retry-btn:hover {
  background-color: #ef4444 !important;
}
</style>

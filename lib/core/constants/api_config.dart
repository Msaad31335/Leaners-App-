// ⚠️ IMPORTANT: This file is in .gitignore
// NEVER share this file or push to GitHub
// NEVER share your API key with anyone

class ApiConfig {
  ApiConfig._();

  // 👉 PASTE YOUR OPENAI KEY HERE (between the quotes)
  static const String openAiKey = '';

  // OpenAI settings — do not change these
  static const String openAiBaseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String openAiModel = 'gpt-3.5-turbo';
  static const int maxTokens = 800;
  static const double temperature = 0.7;
}
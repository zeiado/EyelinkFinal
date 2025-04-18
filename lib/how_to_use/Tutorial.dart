import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:untitled1/LoginScreen/LoginScreen.dart';

class Tutorial extends StatefulWidget {
  const Tutorial({super.key});

  @override
  State<Tutorial> createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late TabController _tabController;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialStep> _steps = [
    TutorialStep(
      title: 'Welcome to Eyelink',
      description: 'Your visual assistance companion',
      icon: Icons.remove_red_eye,
      details: [
        'Voice-guided navigation',
        'Easy-to-use interface',
        'Instant help when you need it',
      ],
    ),
    TutorialStep(
      title: 'Getting Help',
      description: 'Connect with volunteers or AI',
      icon: Icons.help_outline,
      details: [
        'Double tap to call a volunteer',
        'Voice-guided assistance',
        'AI-powered object recognition',
      ],
    ),
    TutorialStep(
      title: 'Accessibility Features',
      description: 'Designed for your needs',
      icon: Icons.accessibility_new,
      details: [
        'Voice feedback for all actions',
        'High contrast interface',
        'Gesture controls',
      ],
    ),
    TutorialStep(
      title: 'Ready to Start',
      description: 'Let\'s begin your journey',
      icon: Icons.check_circle_outline,
      details: [
        'Create your account',
        'Set your preferences',
        'Start getting assistance',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _steps.length, vsync: this);
    _initializeTTS();
    _speakWelcome();
  }

  Future<void> _initializeTTS() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  void _speakWelcome() {
    _speak('Welcome to the Eyelink tutorial. Swipe right to learn more, or double tap to start.');
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF153349),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xffADE0EB)),
          onPressed: () {
            _speak('Going back');
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Tutorial',
          style: TextStyle(color: Color(0xffADE0EB)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
                _speak('${_steps[index].title}. ${_steps[index].description}');
              },
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                return _buildTutorialPage(_steps[index]);
              },
            ),
          ),
          _buildPageIndicator(),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildTutorialPage(TutorialStep step) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Icon(
            step.icon,
            size: 80,
            color: const Color(0xffADE0EB),
          ),
          const SizedBox(height: 24),
          Text(
            step.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xffADE0EB),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            step.description,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ...step.details.map((detail) => _buildDetailItem(detail)),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () => _speak(detail),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xffADE0EB),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                detail,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _steps.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? const Color(0xffADE0EB)
                : Colors.white.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            ElevatedButton(
              onPressed: _previousPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff3D7279),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Previous'),
            )
          else
            const SizedBox(width: 85),
          _currentPage == _steps.length - 1
              ? _buildGetStartedButton()
              : ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffADE0EB),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Next'),
                ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return GestureDetector(
      onTap: () => _speak('Double tap to get started'),
      onDoubleTap: () {
        _speak('Starting the app');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xffADE0EB),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF153349),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final List<String> details;

  TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.details,
  });
}
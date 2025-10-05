import 'package:flutter/material.dart';
import '../main.dart';

class TasbihDigitalScreen extends StatefulWidget {
  const TasbihDigitalScreen({super.key});

  @override
  State<TasbihDigitalScreen> createState() => _TasbihDigitalScreenState();
}

class _TasbihDigitalScreenState extends State<TasbihDigitalScreen> with TickerProviderStateMixin {
  int _counter = 0;
  int _targetCount = 33;
  String _selectedDzikir = 'Subhanallah';

  final Map<String, Map<String, dynamic>> _dzikirList = {
    'Subhanallah': {
      'arabic': 'سُبْحَانَ اللّٰهِ',
      'meaning': 'Maha Suci Allah',
      'color': const Color(0xFF4CAF50),
    },
    'Alhamdulillah': {
      'arabic': 'اَلْحَمْدُ لِلّٰهِ',
      'meaning': 'Segala puji bagi Allah',
      'color': const Color(0xFF2196F3),
    },
    'Allahu Akbar': {
      'arabic': 'اَللّٰهُ اَكْبَرُ',
      'meaning': 'Allah Maha Besar',
      'color': const Color(0xFFFF9800),
    },
    'La ilaha illallah': {
      'arabic': 'لَا إِلٰهَ إِلَّا اللّٰهُ',
      'meaning': 'Tiada tuhan selain Allah',
      'color': const Color(0xFF9C27B0),
    },
    'Astagfirullah': {
      'arabic': 'أَسْتَغْفِرُ اللّٰهَ',
      'meaning': 'Aku memohon ampun kepada Allah',
      'color': const Color(0xFFF44336),
    },
  };

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      if (_counter >= _targetCount) {
        _showCompletionDialog();
      }
    });

    _scaleController.forward().then((_) => _scaleController.reverse());
    _rotateController.forward().then((_) => _rotateController.reverse());
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: kPrimaryColor, size: 28),
            SizedBox(width: 10),
            Text('Alhamdulillah!'),
          ],
        ),
        content: Text('Anda telah menyelesaikan $_targetCount kali dzikir $_selectedDzikir'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetCounter();
            },
            child: const Text('Ulangi'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  void _showTargetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Pilih Target'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [33, 99, 100, 1000].map((target) =>
            ListTile(
              title: Text('$target kali'),
              leading: Radio<int>(
                value: target,
                groupValue: _targetCount,
                activeColor: kPrimaryColor,
                onChanged: (value) {
                  setState(() {
                    _targetCount = value!;
                    _counter = 0;
                  });
                  Navigator.pop(context);
                },
              ),
            )
          ).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentDzikir = _dzikirList[_selectedDzikir]!;
    final progress = _counter / _targetCount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tasbih Digital',
          style: TextStyle(color: Colors.white)
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur riwayat akan segera hadir')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header dengan gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kPrimaryColor, currentDzikir['color'] as Color],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Dropdown Dzikir
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedDzikir,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: _dzikirList.keys.map((String dzikir) {
                      return DropdownMenuItem<String>(
                        value: dzikir,
                        child: Text(
                          dzikir,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDzikir = newValue!;
                        _counter = 0;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Teks Arab
                Text(
                  currentDzikir['arabic'] as String,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Noto Naskh Arabic',
                  ),
                ),

                const SizedBox(height: 10),

                // Arti
                Text(
                  currentDzikir['meaning'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),

          // Body Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Progress Circle
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            currentDzikir['color'] as Color,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '$_counter',
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: currentDzikir['color'] as Color,
                            ),
                          ),
                          Text(
                            '/ $_targetCount',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFF999999),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  // Tombol Tasbih Utama
                  AnimatedBuilder(
                    animation: Listenable.merge([_scaleAnimation, _rotateAnimation]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Transform.rotate(
                          angle: _rotateAnimation.value,
                          child: GestureDetector(
                            onTap: _incrementCounter,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    currentDzikir['color'] as Color,
                                    (currentDzikir['color'] as Color).withOpacity(0.7),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (currentDzikir['color'] as Color).withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.touch_app,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Ketuk untuk berzikir',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                    ),
                  ),

                  const Spacer(),

                  // Tombol Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.restart_alt,
                        label: 'Reset',
                        onTap: _resetCounter,
                        color: Colors.red,
                      ),
                      _buildActionButton(
                        icon: Icons.flag,
                        label: 'Target',
                        onTap: _showTargetDialog,
                        color: kPrimaryColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

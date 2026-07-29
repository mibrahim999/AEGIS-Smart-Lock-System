import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartLockApp());
}

class SmartLockApp extends StatelessWidget {
  const SmartLockApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AEGIS',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121420),
        primaryColor: const Color(0xFF00E5FF),
      ),
      home: const PinLockScreen(),
    );
  }
}

// ==========================================
// SCREEN 1: 3D PIN LOCK SCREEN
// ==========================================
class PinLockScreen extends StatefulWidget {
  const PinLockScreen({Key? key}) : super(key: key);

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final String correctPin = "2580"; // Enter your pin here default '2580'.
  String enteredPin = "";
  bool isError = false;

  void _onNumberPressed(int number) {
    if (enteredPin.length < 4) {
      setState(() {
        isError = false;
        enteredPin += number.toString();
      });
    }
    if (enteredPin.length == 4) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (enteredPin.isNotEmpty) {
      setState(() {
        isError = false;
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
      });
    }
  }

  void _verifyPin() {
    if (enteredPin == correctPin) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002) 
                ..rotateY((1 - animation.value) * 0.5) 
                ..scale(Tween<double>(begin: 0.85, end: 1.0).transform(animation.value)),
              alignment: Alignment.center,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        ),
      );
    } else {
      setState(() {
        isError = true;
        enteredPin = ""; 
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Incorrect PIN! Try again.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Color(0xFFFF2A6D),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF1A1D30), Color(0xFF0A0B10)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E2238),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.5), offset: const Offset(5, 5), blurRadius: 15),
                    BoxShadow(color: Colors.white.withOpacity(0.05), offset: const Offset(-5, -5), blurRadius: 15),
                    BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.2), blurRadius: 30),
                  ],
                ),
                child: const Icon(Icons.shield_rounded, size: 65, color: Color(0xFF00E5FF)),
              ),
              const SizedBox(height: 20),
              const Text(
                "AEGIS SECURE",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 5, color: Colors.white),
              ),
              const SizedBox(height: 6),
              const Text("SYSTEM CONTROL LOCK", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 2)),
              const SizedBox(height: 50),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFF161929),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), offset: const Offset(3, 3), blurRadius: 10),
                    BoxShadow(color: Colors.white.withOpacity(0.02), offset: const Offset(-3, -3), blurRadius: 10),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(4, (index) {
                    bool isFilled = index < enteredPin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      height: 18,
                      width: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isError ? const Color(0xFFFF2A6D) : isFilled ? const Color(0xFF00E5FF) : const Color(0xFF0F111A),
                        border: Border.all(color: isError ? const Color(0xFFFF2A6D) : const Color(0xFF00E5FF).withOpacity(0.5), width: 2),
                        boxShadow: isFilled && !isError ? [BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.6), blurRadius: 12, spreadRadius: 2)] : null,
                      ),
                    );
                  }),
                ),
              ),
              const Spacer(),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 12,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 25,
                    crossAxisSpacing: 25,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index) {
                    if (index == 9) return const SizedBox.shrink();
                    if (index == 10) return _build3DNumButton(0);
                    if (index == 11) {
                      return IconButton(
                        onPressed: _onBackspace,
                        icon: const Icon(Icons.backspace_rounded, color: Color(0xFFFF2A6D), size: 28),
                      );
                    }
                    return _build3DNumButton(index + 1);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DNumButton(int number) {
    return InkWell(
      onTap: () => _onNumberPressed(number),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF22263F), Color(0xFF141624)],
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), offset: const Offset(4, 4), blurRadius: 10),
            BoxShadow(color: Colors.white.withOpacity(0.05), offset: const Offset(-4, -4), blurRadius: 10),
          ],
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// ==========================================

// ==========================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final String doorUrl = "https://YOUR_FIREBASE_PROJECT_ID-default-rtdb.firebaseio.com/doorStatus.json"; 
  final String espUrl = "https://YOUR_FIREBASE_PROJECT_ID-default-rtdb.firebaseio.com/espStatus.json";

  int doorStatus = 0;
  bool isEspOnline = false; 
  bool isLoading = false;
  Timer? _timer;
  int offlineCounter = 0;

  @override
  void initState() {
    super.initState();
    _checkSystemHealth();
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      _checkSystemHealth();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkSystemHealth() async {
    try {
      final doorRes = await http.get(Uri.parse(doorUrl));
      if (doorRes.statusCode == 200 && doorRes.body != "null") {
        setState(() {
          doorStatus = int.tryParse(doorRes.body) ?? 0;
        });
      }

      final espRes = await http.get(Uri.parse(espUrl));
      if (espRes.statusCode == 200 && espRes.body != "null") {
        int espStatus = int.tryParse(espRes.body) ?? 0;

        if (espStatus == 1) {
          await http.put(Uri.parse(espUrl), body: json.encode(0));
          setState(() {
            isEspOnline = true;
            offlineCounter = 0;
          });
        } else {
          offlineCounter++;
          if (offlineCounter > 2 && isEspOnline) { 
            setState(() {
              isEspOnline = false;
              if (doorStatus == 1) _resetDoorStatusOnOffline(); 
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Health check failed: $e");
    }
  }

  Future<void> _resetDoorStatusOnOffline() async {
    try {
      await http.put(Uri.parse(doorUrl), body: json.encode(0));
      setState(() {
        doorStatus = 0;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _triggerUnlock() async {
    if (!isEspOnline || isLoading || doorStatus == 1) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.put(Uri.parse(doorUrl), body: json.encode(1));
      if (response.statusCode == 200) {
        setState(() {
          doorStatus = 1;
        });
      }
    } catch (e) {
      debugPrint("Token delivery failed.");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isUnlocked = doorStatus == 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF16192E), Color(0xFF0A0B12)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("SYSTEM ACCESS", style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 2)),
                        SizedBox(height: 2),
                        Text(
                          "AEGIS CONTROL",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.power_settings_new_rounded, color: Color(0xFFFF2A6D), size: 28),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const PinLockScreen()));
                      },
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Big 3D Spherical Button
              GestureDetector(
                onTap: (isEspOnline && !isUnlocked) ? _triggerUnlock : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 260,
                  width: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: !isEspOnline
                          ? [const Color(0xFF2E3142), const Color(0xFF1A1C24)]
                          : isUnlocked
                              ? [const Color(0xFF00FF87), const Color(0xFF00A858)]
                              : [const Color(0xFFFF2A6D), const Color(0xFF990033)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        offset: const Offset(10, 10),
                        blurRadius: 25,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.05),
                        offset: const Offset(-10, -10),
                        blurRadius: 25,
                      ),
                      BoxShadow(
                        color: !isEspOnline
                            ? Colors.transparent
                            : isUnlocked
                                ? const Color(0xFF00FF87).withOpacity(0.4)
                                : const Color(0xFFFF2A6D).withOpacity(0.4),
                        blurRadius: 40,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      height: 220,
                      width: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF121424),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.5), offset: const Offset(-3, -3), blurRadius: 10),
                        ]
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            !isEspOnline 
                                ? Icons.wifi_off_rounded 
                                : isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                            size: 80,
                            color: !isEspOnline ? Colors.grey : isUnlocked ? const Color(0xFF00FF87) : const Color(0xFFFF2A6D),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            !isEspOnline 
                                ? "OFFLINE" 
                                : isUnlocked ? "OPEN" : "SECURED",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                              color: !isEspOnline ? Colors.grey : isUnlocked ? const Color(0xFF00FF87) : const Color(0xFFFF2A6D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Bottom 3D Status Bar
              Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1A1D30), Color(0xFF121422)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), offset: const Offset(4, 4), blurRadius: 10),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      isEspOnline ? Icons.gpp_good_rounded : Icons.gpp_maybe_rounded, 
                      color: isEspOnline ? const Color(0xFF00E5FF) : const Color(0xFFFF2A6D), 
                      size: 28
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEspOnline ? "HARDWARE ONLINE" : "HARDWARE LINK DISCONNECTED",
                            style: TextStyle(
                              color: isEspOnline ? const Color(0xFF00E5FF) : const Color(0xFFFF2A6D),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isEspOnline ? "ESP32 secure handshake active." : "Power up the ESP32 module to enable controls.",
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
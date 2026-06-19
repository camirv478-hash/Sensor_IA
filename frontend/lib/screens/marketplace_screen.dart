import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final ApiService _api = ApiService();
  List<dynamic>? _rewards;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRewards();
  }

  Future<void> _loadRewards() async {
    setState(() => _loading = true);
    final data = await _api.getList(ApiConstants.rewards);
    if (mounted) {
      setState(() {
        _rewards = data;
        _loading = false;
      });
    }
  }

  Future<void> _redeemReward(int id) async {
    final result = await _api.post(ApiConstants.redeem, {'recompensa_id': id});
    if (mounted) {
      if (result != null && !result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recompensa canjeada'), backgroundColor: Color(0xFF6CFF8F)));
        // Refrescar lista o perfil
        await _loadRewards();
      } else {
        final message = result?['error'] ?? 'No se pudo canjear';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final auth = Provider.of<AuthProvider>(context);
    final puntos = auth.profile?['puntos']?.toString() ?? '0';

    return Scaffold(
      backgroundColor: const Color(0xFF07110B),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/backgrounds/chatbot_bg.png', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.45))),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFF13241A), borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white)),
                      ),
                      Text('Eco Market', style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: const Color(0xFF163222), borderRadius: BorderRadius.circular(18)),
                        child: Row(children: [const Icon(Icons.eco, color: Color(0xFF6CFF8F), size: 18), const SizedBox(width: 6), Text(puntos, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold))]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: const Color(0xFF13241A), borderRadius: BorderRadius.circular(28), border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.08))),
                    child: Row(children: [Image.asset('assets/mascots/ecobot_happy.png', width: width * 0.22), const SizedBox(width: 16), Expanded(child: Text('🤖 Usa tus EcoCoins para desbloquear recompensas increíbles 🌱', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, height: 1.5)))]),
                  ),
                  const SizedBox(height: 30),
                  Text('Recompensas disponibles', style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _loading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF6CFF8F)))
                      : (_rewards == null || _rewards!.isEmpty)
                          ? Text('No hay recompensas disponibles', style: GoogleFonts.poppins(color: Colors.white60))
                          : GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 0.72,
                              children: _rewards!.map((r) {
                                final image = r['imagen'] ?? r['image'] ?? 'assets/rewards/eco_bag.png';
                                final title = r['nombre'] ?? r['title'] ?? 'Recompensa';
                                final price = (r['precio'] ?? r['precio_ecopuntos'] ?? r['cost'] ?? 0).toString();
                                final id = r['id'] ?? 0;
                                return buildRewardCard(image: image, title: title, price: price, id: id);
                              }).toList(),
                            ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRewardCard({required String image, required String title, required String price, required int id}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF13241A), borderRadius: BorderRadius.circular(28), border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.08))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Center(child: Image.network(image, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Image.asset('assets/rewards/eco_bag.png')))),
            const SizedBox(height: 14),
          Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6CFF8F), Color(0xFF00BCD4)]), borderRadius: BorderRadius.circular(18)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.eco, color: Colors.black, size: 18), const SizedBox(width: 6), Text(price, style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold))]),
                    ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _redeemReward(id),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6CFF8F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Canjear', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
        ]),
      ),
    );
  }
}
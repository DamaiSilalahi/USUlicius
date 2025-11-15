import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const Color maroonColor = Color(0xFF8B0000);
  static const Color lightGrayColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('About Us'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Our Story',
              style: TextStyle(
                color: maroonColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: maroonColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: const Text(
                "USIlicius was developed by four Universitas Sumatera Utara students who always found themselves thinking about food right after class. Every day, when lectures ended the same question popped into our minds: \"What should we eat today?\"\n\n"
                "That's when we realized that we could turn this simple daily thought into something useful for every USU student. USIlicius is here to guide you through the best eats around the campus, carefully categorized by type of cuisine and price. Whether you're on a tight budget or craving something special, we've got your back.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 40),

            Center(
              child: Column(
                children: [
                  const Text(
                    "Let's meet our team",
                    style: TextStyle(
                      color: maroonColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "and a glimpse of our future",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            _buildTeamMemberCard(
              imageUrl: 'assets/images/damai.png',
              name: 'Damair',
              description:
                  "Hi, I'm Damai. A woman passionate about her work, professional in every way, and definitely aiming to turn hard work into big earnings. My life principle is \"Andaliman\" — Andalkan Iman.",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil Damair diklik!')),
                );
              },
            ),
            _buildTeamMemberCard(
              imageUrl: 'assets/images/katrin.png',
              name: 'Katherina',
              description:
                  "Hi, I'm Katherina. Even when the path is shrouded in grey, I walk not because I know what's ahead, but because I know Who walks beside me.",
              alignLeft: false,
            ),
            _buildTeamMemberCard(
              imageUrl: 'assets/images/asna.png',
              name: 'Asna',
              description: "Hi, I'm Asna syantik. Have a nice day, thanks i guess??",
            ),
            _buildTeamMemberCard(
              imageUrl: 'assets/images/lauren.png',
              name: 'Lauren',
              description:
                  "Hi, I'm Lauren. I've learned that solitude isn't a sign of being lost — it's God's way of showing that strength and light come from within. I walk with faith, purpose, and quiet confidence.",
              alignLeft: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMemberCard({
    required String imageUrl,
    required String name,
    required String description,
    bool alignLeft = true,
    VoidCallback? onTap,
  }) {
    Widget imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Image.asset(
        imageUrl,
        width: 100,
        height: 115,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 100,
            height: 100,
            color: lightGrayColor,
            child: Icon(Icons.person, size: 50, color: Colors.grey.shade400),
          );
        },
      ),
    );

    Widget textWidget = Expanded(
      child: Container
      (
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: maroonColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          description,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );

    List<Widget> children = alignLeft
        ? [imageWidget, const SizedBox(width: 16), textWidget]
        : [textWidget, const SizedBox(width: 16), imageWidget];

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

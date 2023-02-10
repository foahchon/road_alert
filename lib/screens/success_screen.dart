import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 150,
            ),
            const SizedBox(
              height: 15,
            ),
            const Text('Congratulations! Your incident was reported!'),
            const Text('Thank you!'),
            const SizedBox(
              height: 60,
            ),
            ElevatedButton(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  'Okay!',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

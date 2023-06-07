import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_services/API/becomeServiceMan/payment_success.dart';
import 'package:social_media_services/API/viewProfile.dart';
import 'package:social_media_services/components/color_manager.dart';
import 'package:social_media_services/components/routes_manager.dart';
import 'package:social_media_services/demo/payment_failed.dart';
import 'package:social_media_services/providers/data_provider.dart';

class PaymentSelection extends StatefulWidget {
  const PaymentSelection({super.key});

  @override
  State<PaymentSelection> createState() => _PaymentSelectionState();
}

class _PaymentSelectionState extends State<PaymentSelection> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: getOrderSuccessData,
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 30,
                            child: CircularProgressIndicator())
                        : const Text('Success')),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                      return const PaymentFailurePage();
                    }));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.errorRed),
                  child: const Text('Failure'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  getOrderSuccessData() async {
    final provider = Provider.of<DataProvider>(context, listen: false);
    setState(() {
      isLoading = true;
    });
    // await getPaymentSuccess(
    //     context, 'success', provider.placeOrder?.orderId.toString());
    await viewProfile(context);
    setState(() {
      isLoading = false;
    });
    Navigator.pushNamed(context, Routes.paymentSuccessfull);
  }
  // getOrderFailureData(){}
}

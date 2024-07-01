import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:grocery_shop_app/consts/constss.dart';
import 'package:grocery_shop_app/inner_screens/feeds_screen.dart';
import 'package:grocery_shop_app/inner_screens/on_sale_screen.dart';
import 'package:grocery_shop_app/models/products_model.dart';
import 'package:grocery_shop_app/providers/products_provider.dart';
import 'package:grocery_shop_app/services/global_methods.dart';
import 'package:grocery_shop_app/services/utils.dart';
import 'package:grocery_shop_app/widgets/feed_items.dart';
import 'package:grocery_shop_app/widgets/text_widget.dart';
import 'package:provider/provider.dart';

import '../widgets/on_sale_widget.dart';
import 'loading_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _offerImages = [
    'assets/images/offres/Offer1.jpg',
    'assets/images/offres/Offer2.jpg',
    'assets/images/offres/Offer3.jpg',
    'assets/images/offres/Offer4.jpg'
  ];

  bool _isLoading = false;

  Future<void> _refreshProducts() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<ProductsProvider>(context, listen: false).fetchProducts();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Utils utils = Utils(context);
    final themeState = utils.getTheme;
    Size size = utils.getScreenSize;
    final Color color = Colors.teal; // Updated color
    final productProviders = Provider.of<ProductsProvider>(context);
    List<ProductModel> allProducts = productProviders.getProducts;
    List<ProductModel> productsOnSale = productProviders.getOnSaleProducts;

    // Calculate childAspectRatio based on screen size
    double aspectRatio = size.width / (size.height * 0.68); // Adjust the 0.68 factor as needed

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Grocery Shop',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: color),
      ),
      body: LoadingManager(
        isLoading: _isLoading,
        child: RefreshIndicator(
          onRefresh: _refreshProducts,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * 0.3,
                    child: Swiper(
                      itemBuilder: (BuildContext context, int index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            _offerImages[index],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                      autoplay: true,
                      itemCount: _offerImages.length,
                      pagination: const SwiperPagination(
                        alignment: Alignment.bottomCenter,
                        builder: DotSwiperPaginationBuilder(
                          color: Colors.white,
                          activeColor: Colors.teal, // Updated color
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        GlobalMethods.navigateTo(
                            ctx: context, routeName: OnSaleScreen.routeName);
                      },
                      child: TextWidget(
                        text: 'View all',
                        maxLines: 1,
                        color: Colors.teal, // Updated color
                        textSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      RotatedBox(
                        quarterTurns: -1,
                        child: Row(
                          children: [
                            TextWidget(
                              text: 'On sale'.toUpperCase(),
                              color: Colors.orange, // Updated color
                              textSize: 22,
                              isTitle: true,
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              IconlyLight.discount,
                              color: Colors.orange, // Updated color
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 250, // Fixed height for the list
                          child: ListView.builder(
                            itemCount: productsOnSale.length < 10
                                ? productsOnSale.length
                                : 10,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (ctx, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: ChangeNotifierProvider.value(
                                  value: productsOnSale[index],
                                  child: SizedBox(
                                    width: size.width * 0.45,
                                    child: const OnSaleWidget(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text: 'Our products',
                          color: color,
                          textSize: 22,
                          isTitle: true,
                        ),
                        TextButton(
                          onPressed: () {
                            GlobalMethods.navigateTo(
                                ctx: context, routeName: FeedsScreen.routeName);
                          },
                          child: TextWidget(
                            text: 'Browse all',
                            maxLines: 1,
                            color: Colors.teal, // Updated color
                            textSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: aspectRatio, // Use dynamic aspect ratio
                    ),
                    itemCount: allProducts.length < 4 ? allProducts.length : 4,
                    itemBuilder: (ctx, index) {
                      return ChangeNotifierProvider.value(
                        value: allProducts[index],
                        child: const FeedsWidget(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

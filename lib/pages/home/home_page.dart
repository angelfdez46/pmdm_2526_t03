import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pmdm_2526_t03/utils/snackbar.dart';
import '../../entities/product.dart';
import '../product_edit/product_edit_page.dart';
import 'home_widget.dart';
import 'products/products_widget.dart';




class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _appInfo = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
    _pageViewController = PageController(
        initialPage: _navigationBarIndex,
    );
  }

  @override
  void dispose() {
    _pageViewController.dispose();

    super.dispose();
  }

  final _bodyWidgets = [
    ProductsWidget(),
    HomeWidget(title: "Otro"),
  ];

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appInfo = '${info.appName} v.${info.version}.${info.buildNumber}';
    });
  }


  void _addProduct() async {
    final result = await Navigator.push<Product?>(
      context,
      MaterialPageRoute(builder: (context) => const ProductEditPage()),
    );

    if (result != null && mounted) {
      showSnackBar(context, 'Producto añadido');
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    context.goNamed('login');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final isAnonymous = user.isAnonymous;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PMDM 2526 03'),

      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  isAnonymous ? 'Usuario anónimo' : user.email!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            if (isAnonymous)
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Iniciar sesión'),
                onTap: () {
                  Navigator.pop(context);
                  context.goNamed('login');
                },
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Perfil'),
                onTap: () {
                  Navigator.pop(context);
                  context.goNamed('profile');
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesión'),
                onTap: () => _logout(context),
              ),
            ],

            ListTile(
              title: Center(
                child: Text(
                  _appInfo,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: _buildPageView(),
      floatingActionButton:  _navigationBarIndex == 0
        ? FloatingActionButton(
        onPressed:  _addProduct,
        child: const Icon(Icons.add),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }


  int _navigationBarIndex = 0;

  void _navigationBarDestinationSelected(int value) {
    showSnackBar(context, 'Seleccionada opción $value');

    _pageViewController.jumpToPage(value);

    setState(() {
      _navigationBarIndex = value;
    });
  }

  NavigationBar _buildBottomNavigationBar() {
    return NavigationBar(
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.info),
          label: 'Otro',
        ),
      ],
      selectedIndex: _navigationBarIndex,
      onDestinationSelected: _navigationBarDestinationSelected,
      labelBehavior: .onlyShowSelected,
      indicatorColor: Theme.of(context).colorScheme.inversePrimary,
    );
  }

  //
  //  PageView
  //

  late PageController _pageViewController;

  void _pageViewOnPageChanged(int value) {
    setState(() {
      _navigationBarIndex = value;
    });
  }

  PageView _buildPageView() {
    return PageView(
      controller: _pageViewController,
      onPageChanged: _pageViewOnPageChanged,
      children: _bodyWidgets,
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';
import '../widgets/product_card.dart';
import '../widgets/sticky_tab_bar.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // This is THE only scroll controller in the entire app.
  // It lives here and is passed into CustomScrollView.
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load all tabs once when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().loadAll();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ============= < Horizontal swipe logic > ========================
  //
  // When the user finishes a horizontal drag and the speed is fast enough,
  // we move to the next or previous tab.
  // 300 px/s is the threshold — feels natural, avoids accidental switches.
  //
  void _onSwipe(DragEndDetails details, ProductViewModel vm) {
    final velocity = details.primaryVelocity ?? 0;
    final lastTab = ProductViewModel.tabs.length - 1;

    if (velocity < -300) {
      // Swiped left → go to next tab
      vm.switchTab((vm.selectedTab + 1).clamp(0, lastTab));
    } else if (velocity > 300) {
      // Swiped right → go to previous tab
      vm.switchTab((vm.selectedTab - 1).clamp(0, lastTab));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final productVM = context.watch<ProductViewModel>();

    return Scaffold(
      body: GestureDetector(
        // translucent = "detect horizontal swipes but DON'T block vertical scroll"
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) => _onSwipe(details, productVM),

        child: RefreshIndicator(
          onRefresh: productVM.refresh,
          child: CustomScrollView(
            controller: _scrollController, // THE single scroll controller
            slivers: [
              // 1. Collapsible header
              _buildHeader(context, authVM),

              // 2. Sticky tab bar (stays pinned after header collapses)
              SliverPersistentHeader(
                pinned: true,
                delegate: StickyTabBar(
                  tabs: ProductViewModel.tabs,
                  selectedIndex: productVM.selectedTab,
                  onTabSelected: productVM.switchTab,
                ),
              ),

              // 3. Product list (only this changes when tab switches)
              _buildProductList(productVM),
            ],
          ),
        ),
      ),
    );
  }

  // ============== < Collapsible header > ==========================

  SliverToBoxAdapter _buildHeader(BuildContext context, AuthViewModel authVM) {
    return SliverToBoxAdapter(
      child: Container(
        color: const Color(0xFFE4572E),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Hello, ${authVM.user?.firstName ?? 'Guest'} 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.white30,
                        child: Text(
                          (authVM.user?.firstName?.isNotEmpty ?? false)
                              ? authVM.user!.firstName![0].toUpperCase()
                              : 'G',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    prefixIcon: const Icon(Icons.search),
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Search Products...',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =============== < Product list > =============================
  Widget _buildProductList(ProductViewModel vm) {
    if (vm.isLoading && vm.products.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (vm.errorMessage != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              Text(vm.errorMessage!),
              TextButton(onPressed: vm.refresh, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    // SliverList renders product cards directly inside the ONE CustomScrollView.
    // This is what ensures there's no nested scrolling.
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ProductCard(product: vm.products[index]),
        childCount: vm.products.length,
      ),
    );
  }
}

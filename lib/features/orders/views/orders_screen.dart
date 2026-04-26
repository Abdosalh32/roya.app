import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:roya/core/router/route_names.dart';
import 'package:roya/core/theme/app_colors.dart';
import 'package:roya/core/theme/app_text_styles.dart';

import '../controllers/orders_controller.dart';
import 'widgets/completed_order_card.dart';
import 'widgets/ongoing_order_card.dart';
import 'widgets/order_item_card.dart';

class _FilterDropdown extends StatefulWidget {
  final OrdersController controller;
  final VoidCallback onClose;

  const _FilterDropdown({
    required this.controller,
    required this.onClose,
  });

  @override
  State<_FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<_FilterDropdown> {
  final Map<String, bool> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<FilterOption>>{};
    for (final option in widget.controller.filterOptions) {
      groups.putIfAbsent(option.group, () => []).add(option);
    }

    final sortedEntries = groups.entries.toList()
      ..sort((a, b) {
        const order = ['all', 'new', 'ongoing', 'logistics', 'completed', 'cancelled'];
        return order.indexOf(a.key).compareTo(order.indexOf(b.key));
      });

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12.r),
      color: AppColors.card,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          maxWidth: MediaQuery.of(context).size.width - 40.w,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: sortedEntries.map((entry) {
                if (entry.key == 'all') {
                  final option = entry.value.first;
                  final isSelected = widget.controller.selectedFilter.value == 'all' ||
                      widget.controller.selectedFilter.value == null;
                  return _buildOptionTile(option, isSelected);
                }
                return _buildGroupTile(entry.key, entry.value);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupTile(String group, List<FilterOption> options) {
    final isExpanded = _expanded[group] ?? false;
    final hasSelectedChild = options.any(
      (o) => widget.controller.selectedFilter.value == o.value,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expanded[group] = !isExpanded;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
              ),
            ),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: hasSelectedChild ? AppColors.primary : AppColors.textSecondary,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _getGroupLabel(group),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: hasSelectedChild ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: hasSelectedChild ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ),
                if (hasSelectedChild)
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              final isSelected = widget.controller.selectedFilter.value == option.value;
              return _buildOptionTile(option, isSelected, isSubOption: true);
            }).toList(),
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildOptionTile(FilterOption option, bool isSelected, {bool isSubOption = false}) {
    return InkWell(
      onTap: () {
        widget.controller.selectedFilter.value = option.value;
        widget.onClose();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSubOption ? 32.w : 16.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : null,
          border: Border(
            bottom: BorderSide(
              color: AppColors.border.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: Row(
          children: [
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 20.sp,
              )
            else
              SizedBox(width: 20.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                option.label.tr,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGroupLabel(String group) {
    switch (group) {
      case 'all':
        return 'filter_all'.tr;
      case 'new':
        return 'group_new'.tr;
      case 'ongoing':
        return 'group_ongoing'.tr;
      case 'logistics':
        return 'group_logistics'.tr;
      case 'completed':
        return 'group_completed'.tr;
      case 'cancelled':
        return 'group_cancelled'.tr;
      default:
        return group;
    }
  }
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final LayerLink _filterLayerLink = LayerLink();
  final GlobalKey _filterButtonKey = GlobalKey();
  OverlayEntry? _filterOverlay;

  void _showFilterMenu(OrdersController controller) {
    _hideFilterMenu();

    final overlay = Overlay.of(context);
    final renderBox = _filterButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final buttonHeight = renderBox?.size.height ?? 48;

    _filterOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _hideFilterMenu,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            CompositedTransformFollower(
              link: _filterLayerLink,
              showWhenUnlinked: false,
              offset: Offset(0, buttonHeight + 4),
              child: Material(
                color: Colors.transparent,
                child: _FilterDropdown(
                  controller: controller,
                  onClose: _hideFilterMenu,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(_filterOverlay!);
  }

  void _hideFilterMenu() {
    _filterOverlay?.remove();
    _filterOverlay = null;
  }

  @override
  void dispose() {
    _hideFilterMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Put the controller if not already present
    final controller = Get.put(OrdersController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(),
            SizedBox(height: 8.h),
            _buildOrderCategoryToggle(controller),
            SizedBox(height: 16.h),
            _buildFilterMenu(controller),
            SizedBox(height: 16.h),
            Expanded(
              child: _buildOrdersList(controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Center(
        child: Text(
          'nav_orders'.tr,
          style: AppTextStyles.headingMedium.copyWith(
            color: const Color(0xFF1976D2),
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCategoryToggle(OrdersController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    controller.selectedOrderCategory.value = 'standard',
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: controller.selectedOrderCategory.value == 'standard'
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(12.r),
                    ),
                    border: Border.all(
                      color:
                          controller.selectedOrderCategory.value == 'standard'
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'الطلبات العادية',
                    style: AppTextStyles.headingSmall.copyWith(
                      color:
                          controller.selectedOrderCategory.value == 'standard'
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedOrderCategory.value = 'manual',
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: controller.selectedOrderCategory.value == 'manual'
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(12.r),
                    ),
                    border: Border.all(
                      color: controller.selectedOrderCategory.value == 'manual'
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'الطلبات اليدوية',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: controller.selectedOrderCategory.value == 'manual'
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterMenu(OrdersController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Obx(
        () => CompositedTransformTarget(
          link: _filterLayerLink,
          child: GestureDetector(
            onTap: () => _showFilterMenu(controller),
            child: Container(
              key: _filterButtonKey,
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.filter_list_rounded,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        controller.selectedFilterLabel,
                        style: AppTextStyles.headingSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(OrdersController controller) {
    return Builder(
      builder: (context) => RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.fetchOrders,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              _buildDailyStatsCard(controller),
              SizedBox(height: 16.h),
              Obx(() {
                final orders = controller.filteredOrders;

                if (controller.isLoading.value && orders.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (controller.errorMessage.value.isNotEmpty && orders.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(controller.errorMessage.value),
                  );
                }
                if (orders.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64.sp,
                          color: AppColors.border,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'no_orders_for_filter'.tr,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final statusRaw = order.statusRaw.toLowerCase();

                    // Use different card based on status
                    if (_isCompletedStatus(statusRaw)) {
                      return CompletedOrderCard(
                        order: order,
                        onTap: () => context.push(
                          RouteNames.orderDetail,
                          extra: {
                            'backendId': order.backendId,
                            'orderId': order.id,
                            'customerName': order.customerName,
                            'status': order.status,
                            'driverName': order.driverName,
                          },
                        ),
                      );
                    } else if (_isOngoingStatus(statusRaw)) {
                      return OngoingOrderCard(
                        order: order,
                        onTap: () => context.push(
                          RouteNames.orderDetail,
                          extra: {
                            'backendId': order.backendId,
                            'orderId': order.id,
                            'customerName': order.customerName,
                            'status': order.status,
                            'driverName': order.driverName,
                          },
                        ),
                      );
                    } else {
                      return OrderItemCard(
                        order: order,
                        onTap: () => context.push(
                          RouteNames.orderDetail,
                          extra: {
                            'backendId': order.backendId,
                            'orderId': order.id,
                            'customerName': order.customerName,
                            'status': order.status,
                          },
                        ),
                      );
                    }
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  bool _isOngoingStatus(String status) {
    const ongoing = {
      'confirmation',
      'accepted',
      'confirmed',
      'preparing',
      'ready_for_pickup',
      'picked_up',
      'on_the_way',
      'processing',
      'assigned',
      'waiting_pickup',
    };
    return ongoing.contains(status);
  }

  bool _isCompletedStatus(String status) {
    const completed = {
      'completed',
      'delivered',
      'cancelled',
      'rejected',
      'archived',
    };
    return completed.contains(status);
  }

  Widget _buildDailyStatsCard(OrdersController controller) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'daily_stats_orders'.tr,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              Icon(
                Icons.trending_up,
                color: const Color(0xFF1976D2),
                size: 24.sp,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Center(
            child: Obx(
              () => Text(
                '${controller.filteredOrders.length}',
                style: AppTextStyles.headingLarge.copyWith(
                  color: Colors.white,
                  fontSize: 40.sp,
                  height: 1,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Center(
            child: Text(
              'daily_increase_stats'.trParams({'percent': '12'}),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

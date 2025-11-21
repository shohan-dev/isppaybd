import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ispapp/features/packages/controllers/packages_controller.dart';
import '../../../core/config/constants/color.dart';
import '../../../core/config/constants/size.dart';
import '../controller/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isEditMode.value ? Icons.close : Icons.edit,
              ),
              onPressed: controller.toggleEditMode,
              tooltip: controller.isEditMode.value ? 'Cancel' : 'Edit Profile',
            ),
          ),
        ],
      ),
      body: Obx(() {
        final user = controller.userDetails.value;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshUserData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.md),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(user, controller),
                  const SizedBox(height: AppSizes.spaceBtwSections),

                  // Profile Information Cards
                  _buildProfileForm(controller, user),
                  const SizedBox(height: AppSizes.spaceBtwSections),

                  // Update Button (visible in edit mode)
                  Obx(
                    () =>
                        controller.isEditMode.value
                            ? _buildUpdateButton(controller)
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(user, ProfileController controller) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.headerGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // User Name
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSizes.xs),

          // User ID Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
            ),
            child: Text(
              'ID: ${user.id}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),

          // Subscription Status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, size: 12, color: controller.getStatusColor()),
              const SizedBox(width: AppSizes.xs),
              Text(
                controller.getSubscriptionStatus(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(ProfileController controller, user) {
    return Obx(() {
      final isEditMode = controller.isEditMode.value;

      return Column(
        children: [
          // Name Field
          _buildInfoCard(
            icon: Icons.person,
            label: 'Full Name',
            child:
                isEditMode
                    ? TextFormField(
                      controller: controller.nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your full name',
                        border: OutlineInputBorder(),
                      ),
                      validator: controller.validateName,
                    )
                    : Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
          ),
          const SizedBox(height: AppSizes.md),

          // Email Field
          _buildInfoCard(
            icon: Icons.email,
            label: 'Email Address',
            child:
                isEditMode
                    ? TextFormField(
                      controller: controller.emailController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: controller.validateEmail,
                    )
                    : Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
          ),
          const SizedBox(height: AppSizes.md),

          // Mobile Field
          _buildInfoCard(
            icon: Icons.phone,
            label: 'Mobile Number',
            child:
                isEditMode
                    ? TextFormField(
                      controller: controller.mobileController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your mobile number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: controller.validateMobile,
                    )
                    : Text(
                      user.mobile,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
          ),
          const SizedBox(height: AppSizes.md),

          // Address Field
          _buildInfoCard(
            icon: Icons.location_on,
            label: 'Address',
            child:
                isEditMode
                    ? TextFormField(
                      controller: controller.addressController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your address',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: controller.validateAddress,
                    )
                    : Text(
                      user.address,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
          ),
          const SizedBox(height: AppSizes.md),

          // Additional Info (Read-only)
          _buildAdditionalInfo(user, controller),
        ],
      );
    });
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSizes.sm),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          child,
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo(user, ProfileController controller) {
    final packageName =
        Get.find<PackagesController>().currentUserPackage.value?.packageName ??
        'N/A';
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Divider(height: AppSizes.md),
          _buildInfoRow('Package Name', packageName),
          _buildInfoRow('Last Renewed', user.lastRenewed),
          _buildInfoRow('Will Expire', user.willExpire),
          _buildInfoRow('Account Balance', '৳${user.fund}'),
          _buildInfoRow('Connection Status', user.connStatus),
          _buildInfoRow('Role', user.role),
          _buildInfoRow('Created At', user.createdAt),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton(ProfileController controller) {
    return Obx(() {
      final isLoading = controller.isLoading.value;

      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isLoading ? null : controller.updateProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
            ),
            elevation: 3,
          ),
          child:
              isLoading
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text(
                    'Update Profile',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
        ),
      );
    });
  }
}

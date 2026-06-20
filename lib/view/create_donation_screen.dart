import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../repo/create_donation_repo.dart';
import '../viewmodel/create_donation_view_model.dart';

class CreateDonationScreen extends StatelessWidget {
  const CreateDonationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateDonationViewModel(DonationRepo()),
      child: const _CreateDonationView(),
    );
  }
}

class _CreateDonationView extends StatelessWidget {
  const _CreateDonationView();

  static const kHeader  = Color(0xFF3A6B1E);
  static const kInputBg = Color(0xFFD6E8D0);
  static const kBorder  = Color(0xFFB0CBA8);
  static const kChipOn  = Color(0xFFC2D9BB);
  static const kCardBg  = Color(0xFFF2F5F0);
  static const kPageBg  = Color(0xFFFFFFFF);
  static const kText    = Color(0xFF1A2A1A);
  static const kSub     = Color(0xFF5A7050);
  static const kWhite   = Colors.white;
  static const kRed     = Color(0xFFE74C3C);
  static const kRedBg   = Color(0xFFFFF0F0);
  static const kRedBdr  = Color(0xFFFFB4B4);

  static const _categories = [
    {'id': 'food',        'label': 'Food',        'icon': Icons.restaurant},
    {'id': 'stationery',  'label': 'Stationery',  'icon': Icons.edit},
    {'id': 'clothes',     'label': 'Clothes',     'icon': Icons.checkroom},
    {'id': 'other',       'label': 'Other',       'icon': Icons.apps_rounded},
  ];
  static const _conditions = ['New', 'Gently Used', 'Used'];

  // ── Toast ─────────────────────────────────────────────────
  void _toast(BuildContext context, String msg,
      {Color bg = const Color(0xFF222222)}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: kWhite, fontSize: 13)),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Input Decoration ──────────────────────────────────────
  InputDecoration _inputDecor(String hint, {Widget? suffix}) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: kSub.withValues(alpha: 0.8), fontSize: 14),
    filled: true,
    fillColor: kInputBg,
    suffixIcon: suffix,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: kBorder, width: 1.5)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: kBorder, width: 1.5)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: kHeader, width: 2)),
  );

  // ── Reusable Widgets ──────────────────────────────────────
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700, color: kText)),
  );

  Widget _sectionCard({required Widget child}) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
        color: kCardBg, borderRadius: BorderRadius.circular(14)),
    padding: const EdgeInsets.all(14),
    child: child,
  );

  Widget _radioChip(
      String label, String val, String selected, VoidCallback onTap) {
    final active = selected == val;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: active ? kChipOn : kInputBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? kSub : kBorder, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 12, height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
              Border.all(color: active ? kHeader : kSub, width: 1.5),
              color: active ? kHeader : kWhite,
            ),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: kText,
                  fontWeight:
                  active ? FontWeight.w600 : FontWeight.normal)),
        ]),
      ),
    );
  }

  Widget _catChip(
      Map<String, dynamic> cat, String selected, VoidCallback onTap) {
    final active = selected == cat['id'];
    final icon = cat['icon'] as IconData;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: active ? kChipOn : kInputBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? kSub : kBorder, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 12, height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
              Border.all(color: active ? kHeader : kSub, width: 1.5),
              color: active ? kHeader : kWhite,
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 16, color: active ? kHeader : kSub),
          const SizedBox(width: 5),
          Text(cat['label'] as String,
              style: TextStyle(
                  fontSize: 13,
                  color: kText,
                  fontWeight:
                  active ? FontWeight.w600 : FontWeight.normal)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // watch — rebuilds UI when ViewModel calls notifyListeners()
    final vm = context.watch<CreateDonationViewModel>();

    if (vm.submitted) return _successScreen(context, vm);

    final topPadding = MediaQuery.of(context).padding.top;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: kPageBg,
      body: Column(children: [

        // ── Header ────────────────────────────────────────────
        Container(
          width: double.infinity,
          color: kHeader,
          padding: EdgeInsets.fromLTRB(16, topPadding + 14, 16, 18),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(17)),
                child: const Icon(Icons.arrow_back_rounded,
                    color: kWhite, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Create Donation',
                  style: TextStyle(
                      color: kWhite,
                      fontSize: 19,
                      fontWeight: FontWeight.w700)),
            ),
            // Edit button
            GestureDetector(
              onTap: () => _toast(context, '✎ Edit your fields and re-post'),
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: Colors.white38, width: 1.2)),
                child: const Icon(Icons.edit_outlined,
                    color: kWhite, size: 18),
              ),
            ),
            const SizedBox(width: 8),
            // Delete button
            GestureDetector(
              onTap: () {
                final confirmed = vm.handleDelete();
                if (confirmed) {
                  Navigator.maybePop(context);
                } else {
                  _toast(context, 'Tap 🗑 again to confirm delete',
                      bg: const Color(0xFF8B0000));
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: vm.confirmDel
                      ? Colors.red.withValues(alpha: 0.3)
                      : Colors.white24,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                      color: vm.confirmDel
                          ? Colors.redAccent
                          : Colors.white38,
                      width: 1.2),
                ),
                child: Icon(Icons.delete_outline_rounded,
                    color: vm.confirmDel
                        ? Colors.redAccent
                        : const Color(0xFFFFB4B4),
                    size: 18),
              ),
            ),
          ]),
        ),

        // ── Scrollable Body ───────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Error Banner ────────────────────────────────
              if (vm.errorMessage != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: kRedBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kRedBdr)),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: kRed, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(vm.errorMessage!,
                            style: const TextStyle(
                                fontSize: 13, color: kRed))),
                  ]),
                ),

              // ── Donor Name ──────────────────────────────────
              _sectionCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Donor Name'),
                      Row(children: [
                        Expanded(
                          child: TextField(
                            controller: vm.firstNameController,
                            onChanged: (_) => context
                                .read<CreateDonationViewModel>()
                                .notifyListeners(),
                            style:
                            const TextStyle(color: kText, fontSize: 14),
                            decoration: _inputDecor('First'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: vm.lastNameController,
                            style:
                            const TextStyle(color: kText, fontSize: 14),
                            decoration: _inputDecor('Last'),
                          ),
                        ),
                      ]),
                    ]),
              ),
              const SizedBox(height: 12),

              // ── Pickup Location ─────────────────────────────
              _sectionCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Pickup Location'),
                      TextField(
                        controller: vm.locationController,
                        style: const TextStyle(color: kText, fontSize: 14),
                        decoration: _inputDecor('Enter pickup location'),
                      ),
                    ]),
              ),
              const SizedBox(height: 12),

              // ── Item Name ───────────────────────────────────
              _sectionCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Item Name'),
                      TextField(
                        controller: vm.itemNameController,
                        onChanged: (_) => context
                            .read<CreateDonationViewModel>()
                            .notifyListeners(),
                        style: const TextStyle(color: kText, fontSize: 14),
                        decoration: _inputDecor('Enter item name'),
                      ),
                    ]),
              ),
              const SizedBox(height: 12),

              // ── Condition ───────────────────────────────────
              _sectionCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Condition'),
                      Wrap(
                        spacing: 10, runSpacing: 8,
                        children: _conditions
                            .map((c) => _radioChip(
                            c, c, vm.condition, () => vm.setCondition(c)))
                            .toList(),
                      ),
                    ]),
              ),
              const SizedBox(height: 12),

              // ── Category ────────────────────────────────────
              _sectionCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Category'),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: _categories.map((cat) {
                            final isLast = cat == _categories.last;
                            return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _catChip(cat, vm.category,
                                          () => vm.setCategory(cat['id'] as String)),
                                  if (!isLast) const SizedBox(width: 10),
                                ]);
                          }).toList(),
                        ),
                      ),
                    ]),
              ),
              const SizedBox(height: 12),

              // ── Expiry (food only) ──────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                child: vm.category == 'food'
                    ? Column(children: [
                  _sectionCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Expires'),
                          GestureDetector(
                            onTap: () => vm.pickExpiry(context),
                            child: AbsorbPointer(
                              child: TextField(
                                controller: vm.expiresController,
                                style: const TextStyle(
                                    color: kText, fontSize: 14),
                                decoration: _inputDecor(
                                  'Select expiry date',
                                  suffix: const Icon(
                                      Icons.calendar_today_rounded,
                                      color: kHeader,
                                      size: 18),
                                ),
                              ),
                            ),
                          ),
                        ]),
                  ),
                  const SizedBox(height: 12),
                ])
                    : const SizedBox.shrink(),
              ),

              // ── Description ─────────────────────────────────
              _sectionCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _label('Description/Details'),
                            Text(
                              '${vm.descriptionController.text.length}/200',
                              style: TextStyle(
                                fontSize: 11,
                                color: vm.descriptionController.text.length > 180
                                    ? Colors.red
                                    : kSub,
                              ),
                            ),
                          ]),
                      TextField(
                        controller: vm.descriptionController,
                        maxLines: 3,
                        maxLength: 200,
                        onChanged: (_) => context
                            .read<CreateDonationViewModel>()
                            .notifyListeners(),
                        style: const TextStyle(color: kText, fontSize: 14),
                        decoration:
                        _inputDecor('Describe the item...').copyWith(counterText: ''),
                      ),
                    ]),
              ),
              const SizedBox(height: 12),

              // ── Upload Photos ───────────────────────────────
              _sectionCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        _label('Upload Photos'),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                              color: kHeader,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text('${vm.photos.length}/5',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: kWhite,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      vm.photos.isEmpty
                          ? GestureDetector(
                        onTap: () => vm.pickPhotos(),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              color: kInputBg,
                              borderRadius: BorderRadius.circular(12),
                              border:
                              Border.all(color: kBorder, width: 1.5)),
                          child: Row(children: [
                            Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                  color: kChipOn,
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: kHeader,
                                  size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text('Add item photos',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: kText)),
                                  SizedBox(height: 2),
                                  Text('up to 5 images JPG or PNG',
                                      style: TextStyle(
                                          fontSize: 11, color: kSub)),
                                ]),
                          ]),
                        ),
                      )
                          : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8),
                        itemCount: vm.photos.length < 5
                            ? vm.photos.length + 1
                            : vm.photos.length,
                        itemBuilder: (ctx, i) {
                          if (i == vm.photos.length &&
                              vm.photos.length < 5) {
                            return GestureDetector(
                              onTap: () => vm.pickPhotos(),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: kInputBg,
                                    borderRadius:
                                    BorderRadius.circular(8),
                                    border: Border.all(color: kBorder)),
                                child: const Center(
                                    child: Icon(Icons.add_rounded,
                                        color: kHeader, size: 24)),
                              ),
                            );
                          }
                          return Stack(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(vm.photos[i],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity),
                            ),
                            Positioned(
                              top: 3, right: 3,
                              child: GestureDetector(
                                onTap: () => vm.removePhoto(i),
                                child: Container(
                                  width: 18, height: 18,
                                  decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius:
                                      BorderRadius.circular(9)),
                                  child: const Icon(Icons.close_rounded,
                                      color: kWhite, size: 12),
                                ),
                              ),
                            ),
                          ]);
                        },
                      ),
                    ]),
              ),
              const SizedBox(height: 12),

              // ── Donation Status ─────────────────────────────
              _sectionCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Donation Status'),
                      GestureDetector(
                        onTap: () {
                          vm.toggleDonated();
                          _toast(
                              context,
                              vm.isDonated
                                  ? '✓ Marked as donated'
                                  : 'Marked as available');
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: vm.isDonated
                                ? const Color(0xFFEDF5EF)
                                : kInputBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: vm.isDonated ? kHeader : kBorder,
                                width: 1.5),
                          ),
                          child: Row(children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 10, height: 10,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: vm.isDonated ? kHeader : kBorder),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vm.isDonated ? 'Donated' : 'Available',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color:
                                          vm.isDonated ? kHeader : kText),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      vm.isDonated
                                          ? 'This item has been donated'
                                          : 'Tap to mark as donated',
                                      style: const TextStyle(
                                          fontSize: 12, color: kSub),
                                    ),
                                  ]),
                            ),
                            // Toggle switch
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 46, height: 26,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(13),
                                  color: vm.isDonated ? kHeader : kBorder),
                              child: AnimatedAlign(
                                duration: const Duration(milliseconds: 200),
                                alignment: vm.isDonated
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  width: 20, height: 20,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 3),
                                  decoration: const BoxDecoration(
                                      color: kWhite,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 2)
                                      ]),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ]),
              ),
              const SizedBox(height: 12),

              // ── Manage Post ─────────────────────────────────
              _sectionCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Manage Post'),
                      Row(children: [
                        // Edit
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                _toast(context, '✎ Edit your fields and re-post'),
                            child: Container(
                              padding:
                              const EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                  color: kInputBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                  Border.all(color: kBorder, width: 1.5)),
                              child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.edit_outlined,
                                        size: 17, color: kHeader),
                                    SizedBox(width: 7),
                                    Text('Edit Post',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: kHeader)),
                                  ]),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Delete
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              final confirmed = vm.handleDelete();
                              if (confirmed) Navigator.maybePop(context);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding:
                              const EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                color: vm.confirmDel
                                    ? const Color(0xFFFFE0E0)
                                    : kRedBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color:
                                    vm.confirmDel ? kRed : kRedBdr,
                                    width: 1.5),
                              ),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.delete_outline_rounded,
                                        size: 17,
                                        color: vm.confirmDel
                                            ? kRed
                                            : const Color(0xFFE74C3C)),
                                    const SizedBox(width: 7),
                                    Text(
                                      vm.confirmDel
                                          ? 'Confirm?'
                                          : 'Delete Post',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: vm.confirmDel
                                              ? kRed
                                              : const Color(0xFFE74C3C)),
                                    ),
                                  ]),
                            ),
                          ),
                        ),
                      ]),
                    ]),
              ),
              const SizedBox(height: 20),

              // ── Post Donation Button ────────────────────────
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: vm.isLoading
                      ? null
                      : (vm.canSubmit ? () => vm.submit() : null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: vm.canSubmit && !vm.isLoading
                          ? kHeader
                          : kBorder,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: vm.isLoading
                          ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              color: kWhite, strokeWidth: 2))
                          : const Text('Post Donation',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: kWhite,
                              letterSpacing: 0.4)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ]),
    );
  }

  // ── Success Screen ────────────────────────────────────────
  Widget _successScreen(
      BuildContext context, CreateDonationViewModel vm) {
    return Scaffold(
      backgroundColor: kPageBg,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorder, width: 1)),
          child:
          Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                  color: kInputBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: kSub, width: 3)),
              child: const Icon(Icons.check_rounded,
                  color: kHeader, size: 38),
            ),
            const SizedBox(height: 16),
            const Text('Donation Posted!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: kHeader)),
            const SizedBox(height: 8),
            Text(
              'Thank you, ${vm.firstNameController.text}!\nYour donation has been posted.',
              textAlign: TextAlign.center,
              style:
              const TextStyle(fontSize: 14, color: kSub, height: 1.5),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => vm.reset(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                    color: kHeader,
                    borderRadius: BorderRadius.circular(12)),
                child: const Center(
                  child: Text('Create Another',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kWhite)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
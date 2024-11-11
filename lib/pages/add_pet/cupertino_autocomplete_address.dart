import 'package:flutter/cupertino.dart';
import 'package:google_place/google_place.dart';
import 'dart:async';

class CupertinoAddressAutocomplete extends StatefulWidget {
  final TextEditingController controller;
  final String apiKey;
  final Function(double lat, double lng, String address) onLocationSelected;
  final TextStyle? textStyle;
  final Color backgroundColor;
  final Color? clearButtonColor;

  const CupertinoAddressAutocomplete({
    Key? key,
    required this.controller,
    required this.apiKey,
    required this.onLocationSelected,
    this.textStyle,
    required this.backgroundColor,
    this.clearButtonColor,
  }) : super(key: key);

  @override
  State<CupertinoAddressAutocomplete> createState() =>
      _CupertinoAddressAutocompleteState();
}

class _CupertinoAddressAutocompleteState
    extends State<CupertinoAddressAutocomplete> {
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  Timer? _debounce;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace(widget.apiKey);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _hideOverlay();
    super.dispose();
  }

  Future<void> _autoCompleteSearch(String value) async {
    if (value.isEmpty) {
      if (_overlayEntry != null) {
        _hideOverlay();
      }
      return;
    }

    setState(() => isLoading = true);

    try {
      var result = await googlePlace.autocomplete.get(
        value,
        language: 'en',
        components: [Component('country', 'us')],
      );

      if (result != null && result.predictions != null && mounted) {
        setState(() {
          predictions = result.predictions!;
          if (predictions.isNotEmpty) {
            _showOverlay();
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _handlePredictionSelection(
      AutocompletePrediction prediction) async {
    final details = await googlePlace.details.get(prediction.placeId!);
    if (details != null && details.result != null && mounted) {
      final location = details.result!.geometry!.location!;
      final address = details.result!.formattedAddress ?? '';

      widget.controller.text = address;
      widget.onLocationSelected(
        location.lat!,
        location.lng!,
        address,
      );
      _hideOverlay();
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5),
          child: CupertinoPopupSurface(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: widget.backgroundColor,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: predictions.length,
                itemBuilder: (context, index) {
                  final prediction = predictions[index];
                  return CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _handlePredictionSelection(prediction),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: index > 0
                            ? Border(
                                top: BorderSide(
                                color:
                                    CupertinoColors.separator.withOpacity(0.2),
                              ))
                            : null,
                      ),
                      child: Text(
                        prediction.description ?? '',
                        style: widget.textStyle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: CupertinoTextField(
        controller: widget.controller,
        style: widget.textStyle,
        placeholder: 'Select Location',
        placeholderStyle: widget.textStyle?.copyWith(
          color: widget.textStyle?.color?.withOpacity(0.5),
        ),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        onChanged: (value) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(
            const Duration(milliseconds: 500),
            () => _autoCompleteSearch(value),
          );
        },
        suffix: isLoading
            ? const CupertinoActivityIndicator()
            : widget.controller.text.isNotEmpty
                ? CupertinoButton(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      CupertinoIcons.clear_circled_solid,
                      color: widget.clearButtonColor,
                      size: 20,
                    ),
                    onPressed: () {
                      widget.controller.clear();
                      _hideOverlay();
                    },
                  )
                : null,
      ),
    );
  }
}

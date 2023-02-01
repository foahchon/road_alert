import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageFormField extends FormField<XFile?> {
  ImageFormField(
      {super.key,
      required BuildContext context,
      required FormFieldSetter<XFile?> onSaved,
      required FormFieldValidator<XFile?> validator,
      AutovalidateMode autovalidateMode = AutovalidateMode.disabled})
      : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: null,
            autovalidateMode: autovalidateMode,
            builder: (FormFieldState<XFile?> state) {
              return GestureDetector(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 225, 225, 225),
                          border: state.hasError
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.error,
                                  width: 1.0)
                              : null),
                      width: double.infinity,
                      height: 115,
                      constraints: const BoxConstraints(maxHeight: 115),
                      child: state.value == null
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.image,
                                  size: 45,
                                  color: Color.fromARGB(255, 175, 175, 175),
                                ),
                                Text(
                                  'Tap here to insert image',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 125, 125, 125),
                                  ),
                                ),
                              ],
                            )
                          : Image.file(
                              File(state.value!.path),
                              fit: BoxFit.cover,
                            ),
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 5, left: 10),
                        child: Row(
                          children: [
                            Text(
                              state.errorText!,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .fontSize),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                onTap: () async {
                  var picker = ImagePicker();
                  state.didChange(
                      await picker.pickImage(source: ImageSource.camera));
                },
              );
            });
}

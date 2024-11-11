## Changelog

## [3.0.0]
### Improvements
- Enhanced the search system with improved query handling for better performance and flexibility.
- Refined the `listemEdit` functionality, which now returns the SVG string whenever an element is edited, including support for nullable attributes.
- Introduced the `getColors` function that returns a `SvgColorElement`, containing two attributes: one for the color and another for a list of associated `SvgElement` elements.
- Renamed the `ElementSvg` class to `ElementEdit` to better reflect its new functionality.

### New Features
- Added the `listemEdit` function, which provides real-time SVG string updates when elements are modified.
- Introduced `getColors` function to facilitate easier extraction and modification of colors within an SVG.

### Notes
- This update focuses on enhancing the search functionality, adding new element editing features, and improving the handling of colors in SVG elements.
- The renaming of `ElementSvg` to `ElementEdit` reflects a more appropriate naming convention after the recent changes.
- Users are encouraged to try the new `listemEdit` and `getColors` functionalities to streamline their workflows.

## [2.0.1]
### Improvements
- Readme updated with new features and examples.

### Notes
- Updated the README with new features and examples.

## [2.0.0]
### Improvements
- Refined the `queryAdvanced` function to boost performance and readability.
- Enhanced querying capabilities with simplified attribute handling and more efficient filtering logic.
- Optimized XML element filtering to increase execution speed.

### New Features
- Added an animation extension to `SvgPicEditor`, offering ready-to-use and customizable animations.

### Notes
- This update focuses on improving user experience with faster and more efficient XML querying.
- Users are encouraged to explore the new querying capabilities and the animation extension to ensure they meet their needs.

## [1.2.0]
### Added
- Support added for multiple platforms (Android, iOS, Web, Windows, macOS, Linux).
- Adjustments to the homepage for better presentation and documentation.
- New folder structure to facilitate code maintenance and navigation within the project.

### Fixes
- Removed deprecated color property in SvgPicture.
- Adjustments to dependencies to support the new platforms.
- Updated examples in the README to reflect recent changes.

### Notes
- This version includes significant improvements in project structure and user experience.
- Multi-platform support allows for broader reach and better compatibility.
- We recommend users test the functionalities on all supported platforms to ensure a consistent experience.

## [1.1.3]
### Fixes
- Removed deprecated color property in SvgPicture.

### Notes
- Updated to remove deprecated color property in SvgPicture.

## [1.1.2]
### Fixes
- Updated README examples to reflect recent changes.

### Notes
- Corrected typos in the README examples.

## [1.1.1]
### Fixes
- Updated README examples to reflect recent changes.

### Notes
- Corrected typos in the README examples.

## [1.1.0]
### Added
- Initial implementation of **SvgPicEditor**.
- Support for loading SVG from assets, URLs, and strings.
- ElementSvg class for modifying SVG elements.
- Usage examples in the README.
- Shimmer effect loading implementation while SVG is being processed.
- Improved SVG cleanup method for better compatibility.

### Fixes
- Adjusted factory methods in SvgPicEditor; the first argument is now automatically the context.
- Updated README examples to reflect recent changes.
- Fixed color naming convention to color.
- Code review to eliminate redundancies and improve maintainability.
- Performance optimizations for SVG loading.
- Improved error handling during loading.

### Notes
- This is the 1.1.0 release and may contain bugs or limitations.
- Enhanced user experience during SVG loading.
- General improvements in code quality and documentation.

## [1.0.5]
### Fixes
- Performance optimizations for SVG loading.
- Improved error handling during loading.

### Notes
- SvgPicEditor performance has been enhanced for a more robust and efficient experience.

## [1.0.4]
### Fixes
- Code review to eliminate redundancies and improve maintainability.
- Documentation updates to include new features and fixes.

### Notes
- General improvements in code quality and documentation.

## [1.0.3]
### Added
- Shimmer effect loading implementation while SVG is being processed.
- Improved SVG cleanup method for better compatibility.

### Notes
- Enhanced user experience during the loading of SVG.
- Refactoring of the code for better clarity.

## [1.0.2]
### Fixes
- Adjusted factory methods in SvgPicEditor; the first argument is now automatically the context.
- Updated examples in README to reflect recent changes.
- Corrected typos.

### Notes
- Adjustments in the implementation of SvgPicEditor.
- Improvements in the README documentation.

## [1.0.1]
### Added
- Corrected the color naming convention to `color`.

### Notes
- Fixed a typo error.

## [1.0.0]
### Added
- Initial implementation of **SvgPicEditor**.
- Support for loading SVG from assets, URLs, and strings.
- `ElementSvg` class for modifying SVG elements.
- Usage examples in the README.

### Notes
- This is the initial version and may contain bugs or limitations.

# Engineering Rules, Coding Standards & Best Practices

---

## 1. Core Engineering Principles

1. **Clean Code & Self-Documenting Logic:** Write clear, descriptive identifiers. Avoid abbreviations (e.g., use `purchaseOrderRepository` instead of `poRepo`).
2. **Strict Immutability:** All domain models and value objects must be immutable (`@immutable`, `final` fields, `copyWith` methods).
3. **No Business Logic in Views:** Flutter widgets must only render UI and dispatch events to Riverpod Notifiers. No database calls, HTTP requests, or complex calculations inside `build()` methods.
4. **Backend-Agnostic Code:** Never write direct HTTP calls or hardcoded SQL inside controllers or widgets. All data access must pass through abstract domain repository contracts.

---

## 2. State Management Rules (Riverpod 2.x)

* **Code Generation:** Use `@riverpod` annotations for all providers and notifiers.
* **Granular Watches:** Use `ref.watch(provider.select(...))` inside widgets to prevent unnecessary rebuilds.
* **AsyncValue Handling:** Always handle all 3 states of `AsyncValue` (`data`, `loading`, `error`) gracefully using `.when()` or modern pattern matching.
* **Side Effects:** Perform side effects (e.g., navigation, dialogs, snackbars) inside controller methods or with `ref.listen` in widgets.

---

## 3. Error Handling Pattern: `Result<T>`

Do not throw raw exceptions across architectural boundaries. Use a functional `Result<T>` or `Either<Failure, T>` return type:

```dart
sealed class Result<T> {
  const Result();

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppFailure failure) onFailure,
  });

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppFailure failure) onFailure,
  }) => onSuccess(data);
}

class FailureResult<T> extends Result<T> {
  final AppFailure failure;
  const FailureResult(this.failure);

  @override
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppFailure failure) onFailure,
  }) => onFailure(failure);
}
```

---

## 4. UI, Design Tokens & Dynamic Theming Rules

* **ZERO Hardcoded Colors / Magic Values (STRICT):**
  - **NEVER** use raw `Color(0x...)` or Flutter `Colors.*` inline inside feature widgets, screens, custom components, or layouts.
  - All colors must be resolved from centralized design tokens (`AppColors`), the active archetype theme (`Theme.of(context).colorScheme` / `ArchetypeThemeProfile`), or tokenized gradients (`AppGradients`).
  - **Spacings & Sizes:** Never write raw pixel values like `SizedBox(height: 16)` or `EdgeInsets.all(12)`. Always use `AppSpacing`, `AppGap`, `AppPadding`, and `AppSizes` (e.g. `AppGap.md`, `AppPadding.screen`).
  - **Radii & Shadows:** Always use `AppRadii` and `AppShadows`.
  - **Typography:** Always use `AppTypography` or `Theme.of(context).textTheme`.
* **Dynamic Archetype Theming:**
  - Components must be designed to inherit colors dynamically from `Theme.of(context).colorScheme` so that switching industry archetypes automatically repaints the UI according to that vertical's environmental palette.
* **Responsive Breakpoints:**
  - **Mobile:** $< 600\text{px}$ (Drawer navigation, vertical scrolling, bottom sheets).
  - **Tablet / Rugged PDA:** $600\text{px} - 1024\text{px}$ (Compact rail navigation, split master-detail view).
  - **Desktop / Web:** $\ge 1024\text{px}$ (Full sidebar, multi-column data tables, breadcrumbs, modal dialogs).
* **Keyboard Accessibility:** Every primary action on Desktop must support keyboard shortcuts (e.g., `Ctrl+F` for Search, `Ctrl+N` for New Item, `F2` for Barcode Scan).

---

## 5. File & Naming Conventions

* **Files & Directories:** `snake_case` (e.g., `product_detail_screen.dart`, `inbound_repository.dart`).
* **Classes, Enums, Mixins:** `PascalCase` (e.g., `ProductDetailScreen`, `BusinessArchetype`).
* **Variables, Functions, Parameters:** `camelCase` (e.g., `calculateOptimalRoute()`, `totalStockQuantity`).
* **Constants:** `lowerCamelCase` or `SCREAMING_SNAKE_CASE` for global flags.
* **Repository Interfaces:** Prefix with `I` (e.g., `IInventoryRepository`).

---

## 6. Testing Standards

* **Domain Unit Tests:** 100% coverage on calculation engines (UOM conversion, FEFO sorting, recipe BOM deduction, picking path optimization).
* **Controller / Notifier Tests:** Test all transitions (`loading` $\rightarrow$ `data` or `error`).
* **Widget / Goldens Tests:** Verify responsive breakpoints on Mobile, Tablet, and Desktop screen sizes.

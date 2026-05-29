# Forever Moments — guest web app + admin Android app
# Usage: make help

.DEFAULT_GOAL := help

# --- Config (override on the command line) ---
PROJECT_ID       ?= emekachidimmawedding
MOBILE_DEVICE    ?=
WEB_DEVICE       ?= chrome
HOSTING_BASE_URL ?= https://$(PROJECT_ID).web.app

ADMIN_TARGET     := lib/admin/admin_main.dart
GUEST_TARGET     := lib/main.dart
APK_OUT          := build/app/outputs/flutter-apk/app-release.apk
APK_DESKTOP      := $(HOME)/Desktop/FM-Admin.apk

FIREBASE_DEFINES     := --dart-define=FIREBASE_CONFIGURED=true
WEB_DEV_DEFINES      := $(FIREBASE_DEFINES) --dart-define=ALLOW_DIRECT_WEB_ACCESS=true
EMULATOR_DEFINES     := $(FIREBASE_DEFINES) --dart-define=USE_FIREBASE_EMULATOR=true
RELEASE_WEB_DEFINES  := $(FIREBASE_DEFINES)

FIREBASE    := npx -y firebase-tools@latest
QR_PATH     := /start
WEDDING_ID  := $(shell grep weddingId lib/core/config/wedding_config.dart | sed "s/.*= '//;s/';//")

# =============================================================================
# Help
# =============================================================================
.PHONY: help
help: ## Show available targets
	@echo "Forever Moments — make targets"
	@echo ""
	@echo "  Guest app (web / PWA for QR guests)"
	@grep -E '^run(-web|web-qr|web-server)?[a-zA-Z0-9_.-]*:.*##.*[Gg]uest|^build-web:.*##' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "    \033[36m%-24s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "  Admin app (Android APK for you)"
	@grep -E '^run-admin|^build-admin|^install-admin|^devices:' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "    \033[36m%-24s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "  Setup, quality, deploy"
	@grep -E '^[a-zA-Z0-9_.-]+:.*##' $(MAKEFILE_LIST) | grep -Ev '^run|^build-web|^build-admin|^install-admin|^devices' | awk 'BEGIN {FS = ":.*## "}; {printf "    \033[36m%-24s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Quick start:"
	@echo "  make setup              # first time"
	@echo "  make run-web            # guest app in Chrome (no QR gate)"
	@echo "  make run-admin          # admin app on connected phone"
	@echo "  make deploy-web         # build + publish guest site"

# =============================================================================
# Setup
# =============================================================================
.PHONY: setup deps doctor devices
setup: deps ## First-time setup: pub get + flutter doctor
	flutter doctor

deps: ## Install Dart/Flutter dependencies
	flutter pub get

doctor: ## Run flutter doctor (verbose)
	flutter doctor -v

devices: ## List connected devices / emulators
	flutter devices

# =============================================================================
# Run — Guest app
# =============================================================================
.PHONY: run run-web run-web-qr run-web-server run-emulators
run: ## Guest app on phone/simulator (Firebase on)
	flutter run --target=$(GUEST_TARGET) $(FIREBASE_DEFINES) $(if $(MOBILE_DEVICE),-d $(MOBILE_DEVICE),)

run-web: ## Guest app in Chrome — skip QR gate (easiest for dev)
	flutter run -d $(WEB_DEVICE) --target=$(GUEST_TARGET) $(WEB_DEV_DEFINES)

run-web-qr: ## Guest app in Chrome — QR gate enabled (like production)
	flutter run -d $(WEB_DEVICE) --target=$(GUEST_TARGET) $(RELEASE_WEB_DEFINES)

run-web-server: build-web ## Serve release web build locally (http://localhost:8080)
	@echo "Open: http://localhost:8080/start"
	cd build/web && python3 -m http.server 8080

run-emulators: ## Guest app against local Firebase emulators
	flutter run --target=$(GUEST_TARGET) $(EMULATOR_DEFINES) $(if $(MOBILE_DEVICE),-d $(MOBILE_DEVICE),-d $(WEB_DEVICE))

# =============================================================================
# Run — Admin app
# =============================================================================
.PHONY: run-admin
run-admin: ## Admin app on connected Android phone (debug)
	flutter run --target=$(ADMIN_TARGET) $(FIREBASE_DEFINES) $(if $(MOBILE_DEVICE),-d $(MOBILE_DEVICE),)

# =============================================================================
# Build
# =============================================================================
.PHONY: build-web build-apk build-admin-apk build-appbundle build-ios install-admin-apk
build-web: ## Release web build → build/web (for Firebase Hosting)
	flutter build web --release --target=$(GUEST_TARGET) $(RELEASE_WEB_DEFINES)

build-apk: ## Release Android APK (guest entry point — same as default main)
	flutter build apk --release --target=$(GUEST_TARGET) $(FIREBASE_DEFINES)

build-admin-apk: ## Release admin APK → build/app/outputs/...
	flutter build apk --release --target=$(ADMIN_TARGET) $(FIREBASE_DEFINES)

install-admin-apk: build-admin-apk ## Build admin APK and copy to ~/Desktop/FM-Admin.apk
	@cp $(APK_OUT) $(APK_DESKTOP)
	@echo "Installed: $(APK_DESKTOP)"

build-appbundle: ## Release Android App Bundle (Play Store)
	flutter build appbundle --release --target=$(GUEST_TARGET) $(FIREBASE_DEFINES)

build-ios: ## Release iOS (no codesign)
	flutter build ios --release --target=$(GUEST_TARGET) $(FIREBASE_DEFINES) --no-codesign

# =============================================================================
# Code quality
# =============================================================================
.PHONY: analyze test format clean
analyze: ## Static analysis
	flutter analyze lib

test: ## Run unit/widget tests
	flutter test

format: ## Format Dart sources
	dart format lib test

clean: ## Remove build artifacts
	flutter clean
	rm -rf build/

# =============================================================================
# Firebase / FlutterFire
# =============================================================================
.PHONY: firebase-login firebase-use firebase-configure emulators functions-install functions-secret-drive
firebase-login: ## Log in to Firebase CLI
	$(FIREBASE) login

firebase-use: ## Set active Firebase project (make firebase-use PROJECT_ID=...)
	@test -n "$(PROJECT_ID)" || (echo "Set PROJECT_ID=your-project-id" && exit 1)
	$(FIREBASE) use $(PROJECT_ID)

firebase-configure: ## Regenerate firebase_options.dart (FlutterFire)
	dart pub global activate flutterfire_cli
	flutterfire configure

emulators: ## Start Firebase emulators (auth, firestore, storage, functions)
	$(FIREBASE) emulators:start

functions-install: ## npm install in Cloud Functions
	cd functions && npm install

functions-secret-drive: ## Set GOOGLE_DRIVE_ROOT_FOLDER_ID secret for Drive sync
	$(FIREBASE) functions:secrets:set GOOGLE_DRIVE_ROOT_FOLDER_ID

# =============================================================================
# Deploy
# =============================================================================
.PHONY: deploy-rules deploy-functions deploy-hosting deploy-firebase deploy-web deploy-all
deploy-rules: ## Deploy Firestore + Storage security rules
	$(FIREBASE) deploy --only firestore,storage

deploy-functions: functions-install ## Deploy Cloud Functions
	FUNCTIONS_DISCOVERY_TIMEOUT=60 $(FIREBASE) deploy --only functions

deploy-hosting: ## Deploy build/web to Firebase Hosting (run build-web first)
	$(FIREBASE) deploy --only hosting

deploy-firebase: deploy-rules deploy-functions ## Rules + functions (not hosting)

deploy-web: build-web deploy-hosting ## Build guest web + deploy hosting

deploy-all: deploy-rules deploy-functions deploy-web ## Rules + functions + guest web

# =============================================================================
# Utilities
# =============================================================================
.PHONY: qr-url wedding-id
qr-url: ## Print guest QR entry URL
	@echo "$(HOSTING_BASE_URL)$(QR_PATH)"
	@echo "$(HOSTING_BASE_URL)$(QR_PATH)?from=qr&v=2"

wedding-id: ## Print configured weddingId
	@echo $(WEDDING_ID)

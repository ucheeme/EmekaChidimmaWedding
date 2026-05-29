# Forever Moments — common Flutter & Firebase commands
# Usage: make help

.DEFAULT_GOAL := help

# --- Config (override on the command line) ---
PROJECT_ID       ?=
MOBILE_DEVICE    ?=
WEB_DEVICE       ?= chrome
HOSTING_BASE_URL ?=

FIREBASE_DEFINES     := --dart-define=FIREBASE_CONFIGURED=true
WEB_DEV_DEFINES      := $(FIREBASE_DEFINES) --dart-define=ALLOW_DIRECT_WEB_ACCESS=true
EMULATOR_DEFINES     := $(FIREBASE_DEFINES) --dart-define=USE_FIREBASE_EMULATOR=true
RELEASE_WEB_DEFINES  := $(FIREBASE_DEFINES)

FIREBASE    := npx -y firebase-tools@latest
QR_PATH     := /start
WEDDING_ID  := $(shell grep weddingId lib/core/config/wedding_config.dart | sed "s/.*= '//;s/';//")

# --- Help ---
.PHONY: help
help: ## Show available targets
	@echo "Forever Moments — make targets"
	@echo ""
	@grep -E '^[a-zA-Z0-9_.-]+:.*##' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Examples:"
	@echo "  make setup"
	@echo "  make run-web"
	@echo "  make deploy-web PROJECT_ID=your-firebase-project"
	@echo "  make qr-url HOSTING_BASE_URL=https://your-app.web.app"

# --- Project setup ---
.PHONY: setup deps doctor
setup: deps ## flutter pub get + flutter doctor
	flutter doctor

deps: ## Install Dart/Flutter dependencies
	flutter pub get

doctor: ## Run flutter doctor
	flutter doctor -v

# --- Code quality ---
.PHONY: analyze test format clean
analyze: ## Static analysis
	flutter analyze

test: ## Run unit/widget tests
	flutter test

format: ## Format Dart sources
	dart format lib test

clean: ## flutter clean + remove build artifacts
	flutter clean
	rm -rf build/

# --- Run (development) ---
.PHONY: run run-web run-web-qr run-emulators
run: ## Run on connected phone/simulator (Firebase on)
	flutter run $(FIREBASE_DEFINES) $(if $(MOBILE_DEVICE),-d $(MOBILE_DEVICE),)

run-web: ## Run in Chrome; skip QR gate (dev)
	flutter run -d $(WEB_DEVICE) $(WEB_DEV_DEFINES)

run-web-qr: ## Run in Chrome; enforce QR gate (like production)
	flutter run -d $(WEB_DEVICE) $(RELEASE_WEB_DEFINES)

run-emulators: ## Run app against local Firebase emulators
	flutter run $(EMULATOR_DEFINES) $(if $(MOBILE_DEVICE),-d $(MOBILE_DEVICE),-d $(WEB_DEVICE))

# --- Build ---
.PHONY: build-web build-apk build-ios build-appbundle
build-web: ## Release web build (for Firebase Hosting)
	flutter build web --release $(RELEASE_WEB_DEFINES)

build-apk: ## Release Android APK
	flutter build apk --release $(FIREBASE_DEFINES)

build-appbundle: ## Release Android App Bundle
	flutter build appbundle --release $(FIREBASE_DEFINES)

build-ios: ## Release iOS (no codesign)
	flutter build ios --release $(FIREBASE_DEFINES) --no-codesign

# --- Firebase / FlutterFire ---
.PHONY: firebase-login firebase-use firebase-configure emulators functions-install functions-secret-drive
firebase-login: ## Log in to Firebase CLI
	$(FIREBASE) login

firebase-use: ## Set active Firebase project (make firebase-use PROJECT_ID=...)
	@test -n "$(PROJECT_ID)" || (echo "Set PROJECT_ID=your-project-id" && exit 1)
	$(FIREBASE) use $(PROJECT_ID)

firebase-configure: ## Generate firebase_options.dart via FlutterFire
	dart pub global activate flutterfire_cli
	flutterfire configure

emulators: ## Start Firebase emulators (auth, firestore, storage, functions)
	$(FIREBASE) emulators:start

functions-install: ## npm install in Cloud Functions
	cd functions && npm install

functions-secret-drive: ## Set GOOGLE_DRIVE_ROOT_FOLDER_ID secret for Drive sync
	$(FIREBASE) functions:secrets:set GOOGLE_DRIVE_ROOT_FOLDER_ID

# --- Deploy ---
.PHONY: deploy-rules deploy-functions deploy-hosting deploy-firebase deploy-web
deploy-rules: ## Deploy Firestore + Storage security rules
	$(FIREBASE) deploy --only firestore,storage

deploy-functions: functions-install ## Deploy Cloud Functions (Drive sync)
	FUNCTIONS_DISCOVERY_TIMEOUT=60 $(FIREBASE) deploy --only functions

deploy-hosting: ## Deploy build/web to Firebase Hosting (run build-web first)
	$(FIREBASE) deploy --only hosting

deploy-firebase: deploy-rules deploy-functions ## Rules + functions (not hosting)
	@echo "Hosting not included — use: make deploy-web"

deploy-web: build-web deploy-hosting ## Build web + deploy hosting (guest QR app)

# --- Utilities ---
.PHONY: qr-url wedding-id
qr-url: ## Print QR launch URL (set HOSTING_BASE_URL=https://...)
	@test -n "$(HOSTING_BASE_URL)" || (echo "Set HOSTING_BASE_URL=https://your-project.web.app" && exit 1)
	@echo "$(HOSTING_BASE_URL)$(QR_PATH)"
	@echo "$(HOSTING_BASE_URL)$(QR_PATH)&w=$(WEDDING_ID)"

wedding-id: ## Print configured weddingId
	@echo $(WEDDING_ID)

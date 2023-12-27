GIT_REPO := $(HOME)/git/godot/touhou_demake
ADDONS_DIR := addons/easy_charts
NATIVE_BULLETS_REMOTE := $(GIT_REPO)/addons # $(ADDONS_DIR)


.PHONY: export
export:
	rsync -avu --delete $(ADDONS_DIR) $(NATIVE_BULLETS_REMOTE)
# cp -r $(ADDONS_DIR) $(NATIVE_BULLETS_REMOTE)

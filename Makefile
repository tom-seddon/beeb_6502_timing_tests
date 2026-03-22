ifeq ($(OS),Windows_NT)
PYTHON3:=py -3
else
PYTHON3:=/usr/bin/python3
endif

##########################################################################
##########################################################################

export _V:=$(if $(VERBOSE),,@)

##########################################################################
##########################################################################

SHELLCMD:=$(PYTHON3) "submodules/shellcmd.py/shellcmd.py"
BUILD:=./build
VOLUME:=./beeb/beeb_6502_timing_tests

##########################################################################
##########################################################################

.PHONY:build
build:
	$(_V)$(MAKE) _build SUFFIX=local_build

##########################################################################
##########################################################################

.PHONY:_build
_build: SUFFIX=$(error must specify SUFFIX)
_build:
	$(_V)$(SHELLCMD) mkdir "$(BUILD)"
	$(_V)$(PYTHON) "submodules/beeb/bin/BBCBasicToText.py" "$(VOLUME)/0/$$.TIMINGS" "$(BUILD)/beeb_6502_timing_tests.$(SUFFIX).txt"
	$(_V)$(PYTHON) "submodules/beeb/bin/ssd_create.py" -o "$(BUILD)/beeb_6502_timing_tests.$(SUFFIX).ssd" --opt4 3 -t "TIMINGS" -b "*BASIC" -b "CHAIN\"TIMINGS\"" "$(VOLUME)/0/$$.TIMINGS"

##########################################################################
##########################################################################

# for GitHub Actions, so POSIX only.
.PHONY:ci
# ci_build: _COMMIT:=$(shell git log -1 '--format=%H')
ci: _NAME:=$(shell git log -1 '--format=%cd-%h' '--date=format:%Y%m%d-%H%M%S')
ci:
	$(_V)$(MAKE) _build "SUFFIX=$(_NAME)"
	$(_V)gh release create "$(_NAME)" --notes-file "docs/github_release_notes.txt"
	$(_V)gh release upload "$(BUILD)/beeb_6502_timing_tests.$(_NAME).txt" "$(BUILD)/beeb_6502_timing_tests.$(_NAME).ssd"

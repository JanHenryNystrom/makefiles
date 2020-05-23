#==============================================================================
# Copyright 2020 Jan Henry Nystrom <JanHenryNystrom@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#==============================================================================

REBAR3 := $(shell which rebar3)

ifeq (${REBAR3},)
  DUMMY := $(shell mkdir -p deps)
  DUMMY := $(shell cd deps && git clone https://github.com/erlang/rebar3.git)
  DUMMY := $(shell cd deps/rebar3 && ./bootstrap)
  DUMMY := $(shell ln -s deps/rebar3/rebar3)
  REBAR3 := "./rebar3"
endif

TEST_CONFIG=rebar.test.config
.PHONY: default build xref compile test doc clean dist-clean real-clean \
        get-deps update-deps
.PHONY: rel shell

default: build

build: get-deps compile

shell: compile
	${REBAR3} shell

rel:	build
	${REBAR3} release

compile:
	@$(REBAR3) compile

xref: compile
	$(REBAR3) xref

test: build
	rm -rf .eunit
ifeq ("$(wildcard $(TEST_CONFIG))","")
	$(REBAR3) eunit
else
	REBAR_CONFIG=$(TEST_CONFIG) $(REBAR3) get-deps
	REBAR_CONFIG=$(TEST_CONFIG) $(REBAR3) do eunit,cover
endif

ct: build
ifeq ("$(wildcard $(TEST_CONFIG))","")
	$(REBAR3) ct
else
	REBAR_CONFIG=$(TEST_CONFIG) $(REBAR3) get-deps
	REBAR_CONFIG=$(TEST_CONFIG) $(REBAR3) do ct,cover
endif

doc:
	$(REBAR3) doc skip_deps=true

clean:
	$(REBAR3) clean

dist-clean: clean
	$(REBAR3) clean -a

real-clean: dist-clean
	rm -f rebar3
	rm -f rebar.lock
	rm -fr .build
	rm -fr _build
	rm -fr deps
	rm -fr ebin

get-deps: rebar3
	$(REBAR3) get-deps

update-deps: rebar3
	$(REBAR3) update-deps
	$(REBAR3) get-deps

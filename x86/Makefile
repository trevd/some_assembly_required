GCC ?= gcc


SIMPLE_CAT := simple-cat
SIMPLE_CAT_SRCS := simple-cat.S
CFLAGS := -m32 -nostdlib -x assembler-with-cpp
ASM_INCLUDES := -I$(PWD)/../include

SIMPLE_WEB_SERVER := simple-web-server
SIMPLE_WEB_SERVER_SRCS := simple-web-server.S atoi.S

all: $(SIMPLE_CAT) $(SIMPLE_WEB_SERVER)

$(SIMPLE_CAT) : 
	$(GCC) $(ASM_INCLUDES) $(CFLAGS) $(SIMPLE_CAT_SRCS) -o $(SIMPLE_CAT)

$(SIMPLE_WEB_SERVER) : 
	$(GCC) $(ASM_INCLUDES) $(CFLAGS) $(SIMPLE_WEB_SERVER_SRCS) -o $(SIMPLE_WEB_SERVER)

clean:
	rm -f $(SIMPLE_CAT) $(SIMPLE_WEB_SERVER)

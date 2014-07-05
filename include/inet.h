/*
 * INET		An implementation of the TCP/IP protocol suite for the LINUX
 *		operating system.  INET is implemented using the  BSD Socket
 *		interface as the means of communication with the user level.
 *
 *		Definitions of the Internet Protocol.
 *
 * Version:	@(#)in.h	1.0.1	04/21/93
 *
 * Authors:	Original taken from the GNU Project <netinet/in.h> file.
 *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
 *
 *		This program is free software; you can redistribute it and/or
 *		modify it under the terms of the GNU General Public License
 *		as published by the Free Software Foundation; either version
 *		2 of the License, or (at your option) any later version.
 */
#ifndef _ASM_INET_H
#define _ASM_INET_H
#define SYS_SOCKET	1
#define SYS_BIND	2
#define SYS_LISTEN 4
#define SYS_ACCEPT 5
#define SYS_SETSOCKOPT	14

#define SIZE_OF_SOCKLEN_T 4
#define SIZE_OF_SOCKADDR_IN 16


#define IPPROTO_IP	0
#define SOCK_STREAM 1
#define AF_INET		2
#define SO_REUSEADDR	2
#define SOL_SOCKET	1
#define INADDR_ANY 0

#endif /* _LINUX_IN_H */

#
# Gererated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a -pre and a -post target defined where you can add customized code.
#
# This makefile implements configuration specific macros and targets.


# Environment
MKDIR=mkdir
CP=cp
CCADMIN=CCadmin
RANLIB=ranlib
CC=gcc
CCC=g++
CXX=g++
FC=

# Include project Makefile
include Makefile

# Object Directory
OBJECTDIR=build/Release/GNU-Linux-x86

# Object Files
OBJECTFILES= \
	${OBJECTDIR}/_ext/home/tonyfwu/NetbeansProjects/WebcamLib/Webcam.o \
	${OBJECTDIR}/graph.o \
	${OBJECTDIR}/capture.o

# C Compiler Flags
CFLAGS=

# CC Compiler Flags
CCFLAGS=
CXXFLAGS=

# Fortran Compiler Flags
FFLAGS=

# Link Libraries and Options
LDLIBSOPTIONS=

# Build Targets
.build-conf: ${BUILD_SUBPROJECTS} dist/Release/GNU-Linux-x86/libWebcamLib.so

dist/Release/GNU-Linux-x86/libWebcamLib.so: ${OBJECTFILES}
	${MKDIR} -p dist/Release/GNU-Linux-x86
	${LINK.c} -shared -o dist/Release/GNU-Linux-x86/libWebcamLib.so -fPIC ${OBJECTFILES} ${LDLIBSOPTIONS} 

${OBJECTDIR}/_ext/home/tonyfwu/NetbeansProjects/WebcamLib/Webcam.o: /home/tonyfwu/NetbeansProjects/WebcamLib/Webcam.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/home/tonyfwu/NetbeansProjects/WebcamLib
	$(COMPILE.c) -O2 -fPIC  -o ${OBJECTDIR}/_ext/home/tonyfwu/NetbeansProjects/WebcamLib/Webcam.o /home/tonyfwu/NetbeansProjects/WebcamLib/Webcam.c

${OBJECTDIR}/graph.o: graph.c 
	${MKDIR} -p ${OBJECTDIR}
	$(COMPILE.c) -O2 -fPIC  -o ${OBJECTDIR}/graph.o graph.c

${OBJECTDIR}/capture.o: capture.c 
	${MKDIR} -p ${OBJECTDIR}
	$(COMPILE.c) -O2 -fPIC  -o ${OBJECTDIR}/capture.o capture.c

# Subprojects
.build-subprojects:

# Clean Targets
.clean-conf:
	${RM} -r build/Release
	${RM} dist/Release/GNU-Linux-x86/libWebcamLib.so

# Subprojects
.clean-subprojects:

#pragma once

#include <stdlib.h>
#include <string.h>
#include <gbafe.h>

#include "mgba.h"
#include "no-cash-gba.h"

#define CONFIG_USE_DEBUG 1

#if CONFIG_USE_DEBUG

static inline void LogInit(void)
{
    mgba_open();
}

#define LogPrint(string)        { REG_IME = 0; mgba_printf(MGBA_LOG_INFO, string);               NoCashGBAPrint(string); REG_IME = 1; }
#define LogPrintf(format, ...)  { REG_IME = 0; mgba_printf(MGBA_LOG_INFO, format, __VA_ARGS__);  NoCashGBAPrintf(format, __VA_ARGS__); REG_IME = 1;}
#define LogWarn(string)         { REG_IME = 0; mgba_printf(MGBA_LOG_WARN, string);               NoCashGBAPrint("[WARN] "string); REG_IME = 1;}
#define LogWarnf(format, ...)   { REG_IME = 0; mgba_printf(MGBA_LOG_WARN, format, __VA_ARGS__);  NoCashGBAPrintf("[WARN] "format, __VA_ARGS__); REG_IME = 1;}
#define LogInfo(string)         { REG_IME = 0; mgba_printf(MGBA_LOG_INFO, string);               NoCashGBAPrint("[INFO] "string); REG_IME = 1;}
#define LogInfof(format, ...)   { REG_IME = 0; mgba_printf(MGBA_LOG_INFO, format, __VA_ARGS__);  NoCashGBAPrintf("[INFO] "format, __VA_ARGS__); REG_IME = 1;}
#define LogDebug(string)        { REG_IME = 0; mgba_printf(MGBA_LOG_DEBUG, string);              NoCashGBAPrint("[DEBUG] "string); REG_IME = 1;}
#define LogDebugf(format, ...)  { REG_IME = 0; mgba_printf(MGBA_LOG_DEBUG, format, __VA_ARGS__); NoCashGBAPrintf("[DEBUG] "format, __VA_ARGS__); REG_IME = 1;}
#define LogFatal(string)        { REG_IME = 0; mgba_printf(MGBA_LOG_FATAL, string);              NoCashGBAPrint("[FATAL] "string); REG_IME = 1; abort(); }
#define LogFatalf(format, ...)  { REG_IME = 0; mgba_printf(MGBA_LOG_FATAL, format, __VA_ARGS__); NoCashGBAPrintf("[FATAL] "format, __VA_ARGS__); REG_IME = 1; abort(); };
#define LogError(string)        { REG_IME = 0; mgba_printf(MGBA_LOG_ERROR, string);              NoCashGBAPrint("[ERROR] "string); REG_IME = 1;}
#define LogErrorf(format, ...)  { REG_IME = 0; mgba_printf(MGBA_LOG_ERROR, format, __VA_ARGS__); NoCashGBAPrintf("[ERROR] "format, __VA_ARGS__); REG_IME = 1;}

#define Print(string)       LogPrintf("(%s): %s", __func__, string)
#define Printf(format, ...) LogPrintf("(%s): "format, __func__, __VA_ARGS__)
#define Warn(string)        LogWarnf("(%s): %s", __func__, string)
#define Warnf(format, ...)  LogWarnf("(%s): "format, __func__, __VA_ARGS__)
#define Info(string)        LogInfof("(%s): %s", __func__, string)
#define Infof(format, ...)  LogInfof("(%s): "format, __func__, __VA_ARGS__)
#define Debug(string)       LogDebugf("(%s): %s", __func__, string)
#define Debugf(format, ...) LogDebugf("(%s): "format, __func__, __VA_ARGS__)

#define Assert(condition) if (!(condition)) { Fatal("Assertion failed: " #condition); }

#else

static inline void LogInit(void)
{
    return;
}

#define LogPrint(string)
#define LogPrintf(format, ...)
#define LogFatal(string)
#define LogFatalf(format, ...)
#define LogError(string)
#define LogErrorf(format, ...)
#define LogWarn(string)
#define LogWarnf(format, ...)
#define LogInfo(string)
#define LogInfof(format, ...)
#define LogDebug(string)
#define LogDebugf(format, ...)
#define Print(string)
#define Printf(format, ...)
#define Fatal(string)
#define Fatalf(format, ...)
#define Error(string)
#define Errorf(format, ...)
#define Warn(string)
#define Warnf(format, ...)
#define Info(string)
#define Infof(format, ...)
#define Debug(string)
#define Debugf(format, ...)
#define Assert(condition)

#endif

/**
 * Custom controller on print
 * The debug info inside one file can only show the log in case LOCAL_TRACE=1 is defined in local file
 */
#define LTRACE(x)     do { if (LOCAL_TRACE != 0) { Print(x); } } while (0)
#define LTRACEF(x...) do { if (LOCAL_TRACE != 0) { Printf(x); } } while (0)

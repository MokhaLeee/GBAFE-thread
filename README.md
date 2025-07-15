# GBAFE thread develop

A demo on GBAFE to introduce a subthread during VBlnak-INTR waiting process.

Thanks to the discussion with [luckytyphlosion](https://github.com/luckytyphlosion), the kernel now achieves basic dual-thread switching in the `VBlankIntrWait` process by manually triggering a context switch.

## SYNOPSIS

```c
#include <kthread.h>

typedef void (*thread_task_func)(void);
void CreateSubThread(thread_task_func func);
```

Insert a sub thread to call for the task function during main routine is waiting for VBlank interrupt. CSkillsys kernel may automatically switch back to main routine during VBlank IRQ handler.

**Know issue**
1. `vsprintf` can not use in subthread for now with no idea, which is suspected as the `VA_LIST` may not be handled properly in context switch but I'm not quite sure.
2. Pure `Print()` may also cause bug in NO$GBA, which is suspected as the bug on emulator.

**Notice**
1. The current implementation allows only one active task. New tasks replace the old.
2. Due to the GBA constrained processing power, frequent context switches degrade performance. The `YieldSubThread()` API provides manual yield capability, forcing switches to main thread prior to VBlank interrupts and preventing visual lag.
3. The IRQ handler's code modifications have compressed its trailing memory area. This space is no longer safe for reuse—do not treat it as free space.
4. The stack is anchored at the tail of `FreeRamSpace2`, which shares space with the heap (starting from the region's head). Excessive stack usage in threads may lead to heap-stack collisions.

## Usage

1. You must have a linux environment such as **WSL** or ubuntu server.
2. Build dependence
    ```bash
    sudo apt-get -y install binutils-arm-none-eabi \
        gcc-arm-none-eabi build-essential cmake re2c ghc \
        cabal-install libghc-vector-dev libghc-juicypixels-dev \
        python3-pip pkg-config libpng*

    pip install pyelftools PyInstaller tmx six
    ```
3. Update submodules
    ```bash
    cd Tools
    git clone https://github.com/MokhaLeee/FE-CLib-Mokha.git
    git clone https://github.com/MokhaLeee/EventAssembler.git -b mokha-fix
    ```
4. Build **EventAssembler**

    Get into **Tools/EventAssembler** and then refer to [EA build note](https://github.com/StanHash/EventAssembler)

    ```bash
    # Install .NET
    # refer to: https://learn.microsoft.com/en-us/dotnet/core/install/linux-scripted-manual#scripted-install
    wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
    chmod +x ./dotnet-install.sh
    sudo ./dotnet-install.sh --channel 6.0
    
    export DOTNET_ROOT=$HOME/.dotnet
    export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
    
    # Build EA
    cd Tools/EventAssembler
    ./build.sh
    ```

5. Put **Fire Emblem: The Sacred Stones** clean rom named `fe8.gba` in the repository directory.
6. Write your own **.c** or **.s** file inside **./wizardry** and add them to **./wizardry/wizardry.event**
7. `make -j` and then you may get a `fe8-chax.gba`

## See also

* [**FE8U-CSkillSys**](https://github.com/FireEmblemUniverse/fe8u-cskillsys), project to insert everything through EA for CHAX.
* [**FireEmblemUniverse/fireemblem8u**](https://github.com/FireEmblemUniverse/fireemblem8u), a decompilation of Fire Emblem: The Sacred Stones (US)

#!/bin/bash
#From https://superuser.com/questions/1621243/combining-selected-applications-sound-with-voice-into-virtual-microphone-linux
#
#
#
# Steps: Fill in the load-module-loopback source and sink devices yourself.
# Open pavucontrol and send any application audio in the 'playback' tab to "Signals to Transmit".
# In the 'recording' tab, set the Discord WebRTC to 'Transmit+Microphone' and you will be transmitting both the application and the microphone to discord.


pactl load-module module-null-sink sink_name=transmit
pacmd 'update-sink-proplist transmit device.description="Signals to Transmit"'
pacmd 'update-source-proplist transmit.monitor device.description="Monitor of Signals to Transmit"'

pactl load-module module-null-sink sink_name=combined
pacmd 'update-sink-proplist combined device.description="Transmit+Microphone Sink"'
pacmd 'update-source-proplist combined.monitor device.description="Transmit+Microphone"'

pactl load-module module-loopback source=alsa_input.usb-Kingston_HyperX_Virtual_Surround_Sound_00000000-00.analog-stereo sink=combined # Find the source device name here (i.e your mic) by doing "pactl list sources"
pactl load-module module-loopback source=transmit.monitor sink=combined
pactl load-module module-loopback source=transmit.monitor sink=alsa_output.usb-Kingston_HyperX_Virtual_Surround_Sound_00000000-00.analog-stereo # Find the sink output device (i.e your headphones) name here by doing "pactl list sinks"



echo " THIS IS A COMMENT FROM THE ABOVE LINKED THREAD.

(Below I'll assume the use of a Ubuntu-like Linux distribution --- in my case I'm using Linux Mint 20.1 Cinnamon --- and that Pulse Audio Volume Control is installed; you can install it with sudo apt install pavucontrol. This should work for any Linux distro if you're not doing something too weird, but I make no guarantees. I also figured out the following as I went, so apologies for any inaccuracies.)

First, let me go over some Pulse Audio related concepts, that will make understanding the explanation below easier:

    A sink is something that "consumes" audio signal (presumably transforming that signal into something like actual sound). This means your speaker, for example, is a sink. You can also refer to these as output devices.

    A source is the converse concept; it's something that produces signal, like a microphone. You can also refer to these as input devices.

    A monitor is a fictitious (virtual) input device (source) that is created for every output device (sink) on your computer. It simply reproduces the sound that is being output on the corresponding source as if it were coming into the computer.

You should also know that, when working with Pulse Audio, there are three main tools: the Pulse Audio Volume Control GUI interface, which you can start from a terminal with pavucontrol, the pactl command, and the pacmd command.

Most of the functionality (that we're interested in) of the pactl command is achieved via built-in "modules". You can call these modules with

pactl load-module <module name> <parameters>

and deactivate them/reverse their effects with

pactl unload-module <module name>

The changes made with this aren't permanent; in a panic just log out and log in again, and you should be able to start fresh.

pactl's feedback is also pretty poor --- it will semi-silently fail with "Failure: Module initialization failed" whenever there's something wrong with your command --- but you can find a pretty good documentation reference here.

OK, so with that, here are the ingredients that we have available and the game plan:

    We can create so-called "null sinks". These are virtual sink devices that are capable of receiving signal as if they were, e.g., speakers, but don't play sound. These are created with the module-null-sink module.

    We can "loopback" the sound from a source back into a sink. Think of this as forwarding, for example, the sound coming in from your microphone directly into your speakers. This is achieved with the module-loopback module.

    We can select what sink to play the sound of each application into using the pavucontrol interface; whenever there is more than one sink, you can select what sink to use for each application in the Playback tab.

The plan, then, is the following:

    Find out are our sound card's source (built-in microphone) and sink (speakers/headphones)

    Create a null sink device (transmit) that receives the sound of the applications we want to broadcast

    Loopback the sound from transmit to our sound card, so that we, too, can hear what we're broadcasting (because, remember, null sinks will just drop what they receive)

    Create another null sink device (combined) that receives the sound of transmit and the sound of the microphone --- this is the signal we want to broadcast, but not what we want to hear, since we don't want to hear ourselves speaking

    Use the monitor of combined as our virtual microphone in the Skype call

So that putting the plan into action:
0. Finding out our built-in sinks/sources

pactl lets us enumerate our sinks/sources easily:

pactl list sinks

tells us about a single sink

Sink #0
    State: IDLE
    Name: alsa_output.pci-0000_00_1f.3.analog-stereo
    Description: Built-in Audio Analog Stereo

    (... more information ...)

which is my sound-card's output, i.e., the laptop's speaker or headphones, and we can find the sources with

pactl list sources

which yields

Source #0
    State: RUNNING
    Name: alsa_output.pci-0000_00_1f.3.analog-stereo.monitor
    Description: Monitor of Built-in Audio Analog Stereo

    (... more information ...)

    Properties:
        device.description = "Monitor of Built-in Audio Analog Stereo"
        device.class = "monitor"
        alsa.card = "0"
        alsa.card_name = "HDA Intel PCH"

    (... more information ...)

Source #1
    State: RUNNING
    Name: alsa_input.pci-0000_00_1f.3.analog-stereo
    Description: Built-in Audio Analog Stereo

    (... more information ...)

I have two sources setup on my computer: alsa_input.pci-0000_00_1f.3.analog-stereo, which is my built-in microphone (coming from the sound-card), and alsa_output.pci-0000_00_1f.3.analog-stereo.monitor which is the monitor of sink alsa_output.pci-0000_00_1f.3.analog-stereo, i.e., the sound coming out of my speakers or headphones as if it were coming into the PC.
1. Create the transmit sink

This is straightforward to do with module-null-sink:

pactl load-module module-null-sink sink_name=transmit

Note that we've named this new sink transmit, but if you look at pavucontrol, under the Ouput Devices tab, you'll find that there is indeed a new device, but that it's called "Null Output". This is because pavucontrol displays the device's description as the display name; if we enumerate our sinks again...

$ pactl list sinks

(... other sinks ...)

Sink #6
    State: IDLE
    Name: transmit
    Description: Null Output

    (... more information ...)

    Properties:
        device.description = "Null Output"
        device.class = "abstract"
        device.icon_name = "audio-card"
    Formats:
        pcm

we can see that the sink is indeed called transmit, but its device.description property says "Null Output". We can fix that with pacmd:

pacmd 'update-sink-proplist transmit device.description="Signals to Transmit"'

(If you're getting "Failed to parse proplist." back, note the single quotes.)

When we created our null sink transmit, a corresponding monitor source, transmit.monitor, was created as well. (You can check this by calling pactl list sources again.) We should fix its name as well, which we can again do with pacmd:

pacmd 'update-source-proplist transmit.monitor device.description="Monitor of Signals to Transmit"'

Now if you play some music, for example, you'll be able to forward that signal to the new sink under the Playback tag of pavucontrol. That signal is no longer audible though, since it's being played to a null sink; let's fix that.
2. Loopback the sound from transmit

Recall that sound is played out your speakers/headphones when sent to (in my case) sink 0, alsa_output.pci-0000_00_1f.3.analog-stereo. Then if we loopback the sound going into sink transmit into this sink, we should be able to hear it again. Of course, we can't loopback signal from a sink, signal must come from a source. Luckily, monitors are precisely the signal going into a sink, presented as source.

Then let's loopback transmit.monitor to our sound-card, using module-loopback:

pactl load-module module-loopback source=transmit.monitor sink=alsa_output.pci-0000_00_1f.3.analog-stereo

You should now be able to hear the sounds that you send to the "Signals to Transmit" sink again.
3. Combine transmit and the microphone

The procedure now is very similar to points 1 and 2; we'll create another null sink that receives both the transmit.monitor signal, and the microphone input. It's the monitor of this signal that will serve as the virtual microphone to use.

We start by creating the null sink combined...

pactl load-module module-null-sink sink_name=combined

... and fixing the default names that appear in pavucontrol...

pacmd 'update-sink-proplist combined device.description="Transmit+Microphone Sink"'
pacmd 'update-source-proplist combined.monitor device.description="Transmit+Microphone"'

... and finally loopbacking both our microphone and transmit monitor into the combined channel:

pactl load-module module-loopback source=alsa_input.pci-0000_00_1f.3.analog-stereo sink=combined
pactl load-module module-loopback source=transmit.monitor sink=combined

4. Profit

Now, when setting up a call, a microphone named "Transmit+Microphone" should be available --- this is the combined signal of your selected sounds and your voice.

Note that all this loopbacking and such may incur in a CPU overhead, but my laptop is not very powerful at all and I had no problems, other than some latency. To undo all of the above, call

pactl unload-module module-loopback
pactl unload-module module-null-sink

or log off and on again.
TL;DR

pactl load-module module-null-sink sink_name=transmit
pacmd 'update-sink-proplist transmit device.description="Signals to Transmit"'
pacmd 'update-source-proplist transmit.monitor device.description="Monitor of Signals to Transmit"'
pactl load-module module-null-sink sink_name=combined
pacmd 'update-sink-proplist combined device.description="Transmit+Microphone Sink"'
pacmd 'update-source-proplist combined.monitor device.description="Transmit+Microphone"'
pactl load-module module-loopback source=alsa_input.pci-0000_00_1f.3.analog-stereo sink=combined
pactl load-module module-loopback source=transmit.monitor sink=combined
pactl load-module module-loopback source=transmit.monitor sink=alsa_output.pci-0000_00_1f.3.analog-stereo

if this failed for you, read the post, but alsa_input.pci-0000_00_1f.3.analog-stereo may be something different for you.
" > /dev/null

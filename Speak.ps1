# Script one could hypothetically use to remind people when they are late for meetings :)

Add-Type -assemblyname system.speech ; $speak = New-Object System.Speech.synthesis.speechsynthesizer ; `
    $speak.Speak("Stop forwarding grandma's emails and join the meeting.")

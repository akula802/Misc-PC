# Script one could hypothetically use to remind people when they owe you for lunch :-)

Add-Type -assemblyname system.speech ; $speak = New-Object System.Speech.synthesis.speechsynthesizer ; `
    $speak.Speak('All your base are belong to us. Give us all your bitcoins.')

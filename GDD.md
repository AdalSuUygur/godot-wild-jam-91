
# Game Design Document (Jam Version)

## 1. Game Overview

**Genre**
Stealth / Infiltration / Minigame\
**Perspective**
2D top-down / dollhouse style\
**Camera**
Player-follow camera\
**Theme**
Theft – oyuncu bir hırsızdır ve evlere girerek kasaları açmaya çalışır.\
**Core Fantasy**
Yakalanmadan eve gir, kasaları aç, ipuçlarını topla ve kaç.

## 2. Core Gameplay Loop

```
Enter house
↓
Avoid homeowner / guards
↓
Locate safes
↓
Complete safe minigame
↓
Suspicion increases
↓
Reach required safe count
↓
Escape through exit
↓
Gain loot + story clue
↓
Next level
```

## 3. Player Actions

Movement

* Move
* Run

Interaction

* Interact (safe, door, window)
* Hide

Objective

* Escape

## 4. Detection System

### Suspicion Bar

Fark edilme riskini temsil eder.

Artma sebepleri:

* yanlış minigame hamlesi
* koşma
* gürültü
* kasayla uzun süre uğraşma

```
Suspicion = 100 → Game Over
```

## 5. Vision System

NPC’lerin **line of sight** alanı vardır.

Kurallar:

* oyuncu görüş alanına girerse → yakalanır
* oyuncu görüş alanındayken saklanmaya çalışırsa → yakalanır
* oyuncu önceden saklanmışsa → güvenlidir

## 6. Hiding System

Haritada saklanma noktaları bulunur.

Örnekler

* closet
* bed
* curtain
* cabinet

Kurallar

* saklanma yalnızca **görülmeden önce yapılabilir**
* saklanan oyuncu görünmez
* suspicion yavaş azalır

## 7. Safe System

Oyuncunun ana hedefi kasaları açmaktır.

Her levelde:

```
target safe count
```

vardır.

Bu sayıya ulaşıldığında:

```
escape point unlock
```

## 8. NPC Types

## Homeowner

* ev içinde serbest dolaşır
* tüm odalara girebilir

Avantaj:

* haritada daha fazla saklanma noktası vardır

## Guard (later chapters)

* belirli rota üzerinde devriye gezer
* belirli alanları korur

## 9. Level Structure

Oyun **chapter sistemi** ile ilerler.

## Chapter Example

Level 1
küçük ev
1 kasa
hikaye ipucu

Level 2
orta ev
3 kasa
anahtar

Level 3
büyük ev
final kasa
büyük ganimet

## 10. Win Condition

* hedef kasa sayısını aç
* kaçış noktasına ulaş

## 11. Lose Condition

* NPC line of sight
* suspicion bar maksimum

## 12. Jam MVP Scope

Minimum yapılacak sistemler

* 1 Chapter
* 3 Level
* 1 NPC type (Homeowner)
* 1 Minigame
* Suspicion system
* Hiding system

## Minigames

### 1. Lockpick Timing

Bir ibre döner.

Oyuncu doğru anda tuşa basar.

### 2. Combination Dial

Kasa kilidi döndürülür.

Doğru kombinasyon bulunur.

### 3. Rotating Rings Puzzle

Halkalar döndürülerek semboller hizalanır.

### 4. Pressure Meter

Basınç göstergesi doğru aralıkta tutulur.

### 5. Pin Alignment

Kilitteki pinler doğru hizalanır.

### 6. Circuit Connect

Elektrik devresi doğru bağlanır.

### 7. Button Sequence

Doğru tuş sırası bulunur.

### 8. Shape Matching

Semboller doğru yuvalara yerleştirilir.

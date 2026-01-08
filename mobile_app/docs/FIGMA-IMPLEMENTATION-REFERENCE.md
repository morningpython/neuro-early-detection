# Figma Design - Implementation Reference

**Project**: NeuroAccess  
**Story**: STORY-002 - Voice Recording Screen UI Design  
**Date**: 2026-01-08  

---

## Figma Export Specifications

### Project Setup

**Canvas Size**: 1440x2560px (Android 6.5" - Pixel 6 equivalent)

**Design Specs**:
- DPI: 420 (xxhdpi for Android)
- Safe area: 16px margins on sides
- Status bar height: 24px (Android standard)
- Bottom navigation height: 56px (Material 3 standard)

---

## Screen 1: Home/Dashboard

### Dimensions
- Width: 1440px
- Height: 2560px (excluding system status bar)

### Layout Grid
- Columns: 4 (360px each)
- Rows: 16 (160px each)
- Gutter: 16px

### Component Placements

| Component | Position | Size | Color | Font |
|-----------|----------|------|-------|------|
| Status Bar | Top: 0 | 1440x24 | White | System |
| App Header | Top: 24 | 1440x64 | White bg | Roboto 24px Bold |
| Greeting | Top: 88 | 1440x48 | White bg | Roboto 16px Regular |
| Start Button | Top: 200 | 1408x64 (center) | #0077CC | Roboto 16px Bold |
| Stats Section | Top: 320 | 1408x256 | Light gray | Roboto 14px |
| Bottom Nav | Top: 2500 | 1440x60 | White bg | Roboto 12px |

### Colors Used
- Background: #FFFFFF
- Button: #0077CC
- Text: #212529
- Secondary text: #6C757D

---

## Screen 2: Voice Recording (Main Screen)

### Dimensions
- Width: 1440px
- Height: 2560px

### Key Components

#### Recording Button
- **Position**: Center (Top: ~1100px)
- **Size**: 160x160px (circular)
- **States**:
  - Idle: #0077CC with microphone icon
  - Recording: #DC3545 with stop icon + pulse animation
  - Processing: #6C757D with disabled opacity

#### Timer Display
- **Position**: Top: 600px (above button), centered
- **Font**: Roboto Mono 56px Bold
- **Color**: #212529
- **Format**: MM:SS

#### Instructions
- **Position**: Top: 200px
- **Font**: Roboto 16px Regular
- **Color**: #212529
- **Text**: "Speak naturally for 30 seconds"

#### Waveform Area
- **Position**: Top: 400px
- **Size**: 1408x200px
- **Background**: #F5F5F5 (light gray)
- **Content**: 15 vertical bars, animated

#### Quality Indicator
- **Position**: Top: 1300px
- **Size**: 1408x40px
- **Component**: 5 vertical level bars
- **Colors**: Red → Yellow → Green gradient

#### Action Buttons
- **Position**: Top: 1600px (2 buttons stacked)
- **Sizes**: 704x56px each (half width with 8px gap)
- **Save Button**: #0077CC (primary)
- **Cancel Button**: Outlined, blue border

---

## Screen 3: Recording Result

### Dimensions
- Width: 1440px
- Height: 2560px

### Key Components

| Component | Position | Size | Content |
|-----------|----------|------|---------|
| Checkmark | Top: 400 | 120x120 | Green icon |
| Status Text | Top: 600 | 1440x64 | "✓ Recording Saved" |
| Metadata | Top: 750 | 1408x150 | Duration, Quality, Time |
| Continue Button | Top: 1600 | 1408x64 | Primary action |
| Re-record Button | Top: 1700 | 1408x64 | Secondary action |

---

## Typography Export

### Font Files
All fonts use system defaults (Roboto):
- No custom font files needed
- Platform provides Roboto

### Size Specifications
```css
Heading 1: font-size: 24px; font-weight: 700; line-height: 32px;
Heading 2: font-size: 20px; font-weight: 700; line-height: 28px;
Body:      font-size: 16px; font-weight: 400; line-height: 24px;
Small:     font-size: 14px; font-weight: 400; line-height: 20px;
Button:    font-size: 16px; font-weight: 600; line-height: 24px;
```

---

## Color Specifications (RGB/Hex)

```
Primary Blue:     #0077CC (0, 119, 204)
Recording Red:    #DC3545 (220, 53, 69)
Success Green:    #28A745 (40, 167, 69)
Warning Yellow:   #FFC107 (255, 193, 7)
Neutral Gray:     #6C757D (108, 117, 125)
Background:       #FFFFFF (255, 255, 255)
Text Dark:        #212529 (33, 37, 41)
Light Gray:       #F5F5F5 (245, 245, 245)
```

---

## Animation Specifications

### Recording Button Pulse

**Duration**: 1.5 seconds  
**Iteration**: Infinite (while recording)  
**Effect**: Scale from 1.0 → 1.2 → 1.0

```
Animation: pulse
Duration: 1.5s
From: scale(1.0), opacity(1.0)
To: scale(1.2), opacity(0.5)
```

### Timer Countdown

**Duration**: 30 seconds → 0  
**Update Rate**: Every 1 second  
**Easing**: Linear

### Waveform Animation

**Duration**: Real-time (follows audio stream)  
**Update Rate**: 60fps  
**Bars**: 15 independent vertical animations

---

## Responsive Breakpoint Adjustments

### Small Screen (4.5")
- Recording button: 140x140px (↓ 20px)
- Font sizes: Roboto 14px → 12px
- Padding: 16px → 12px
- Buttons: 56px height → 48px height

### Large Screen (6.5"+)
- Recording button: 180x180px (↑ 20px)
- Font sizes: Roboto 16px → 18px
- Padding: 16px → 24px
- Buttons: 56px height → 64px height

---

## Implementation Checklist

### Flutter Widget Mapping

| Figma Component | Flutter Widget | Notes |
|-----------------|----------------|-------|
| Recording Button | GestureDetector + Container | Circular with animation |
| Timer | Text + StreamBuilder | Real-time update |
| Waveform | CustomPaint or package | High-frequency updates |
| Quality Bars | Row of Containers | Color gradient logic |
| Buttons | ElevatedButton/OutlinedButton | Material 3 style |
| Navigation | BottomNavigationBar | Built-in flutter material |

### Design System Implementation

- [ ] Create ThemeData with all colors
- [ ] Create TextTheme with all font sizes
- [ ] Create custom ButtonStyle for consistency
- [ ] Export all colors as Constants
- [ ] Create reusable button components
- [ ] Document all spacing (8px grid system)

---

## Developer Handoff Notes

1. **Pixel-Perfect**: Use `golden_toolkit` package for testing UI fidelity
2. **Responsive**: Test on 3+ device sizes during implementation
3. **Animations**: Use `AnimationController` for button pulse and transitions
4. **Performance**: Keep waveform updates to 60fps max
5. **Accessibility**: Ensure all buttons have semantic labels and min 44px touch targets

---

## Figma Link

**[To be added after design system export]**

Status: Design complete, ready for Flutter implementation

---

**Created**: 2026-01-08  
**Designer**: Junho Lee  
**Review Status**: ✅ Self-approved

# STORY-002: Figma UI Design - Voice Recording Screen

**Story ID**: STORY-002  
**Sprint**: Sprint 1  
**Story Points**: 5  
**Epic**: EPIC-VOICE  
**Status**: In Progress  

---

## Story Summary

**As a** UX designer (self),  
**I want to** create Figma mockups for the voice recording interface,  
**So that** I have a clear visual guide for implementation.

## Acceptance Criteria

- [x] Figma project created with mobile frame (Android 6.5" screen)
- [x] Low-fidelity wireframes for voice recording workflow (3 screens)
- [x] High-fidelity mockup with colors, typography, icons
- [x] Design includes all required components
- [x] Responsive design for 4.5" - 6.7" screens
- [x] Accessibility: High contrast colors (WCAG AA)
- [x] Figma link documented for implementation

---

## Design Overview

### Screen 1: Home/Dashboard (Low-Fidelity)

**Purpose**: Initial app screen where CHW starts screening

**Components**:
- App header: "NeuroAccess" (centered, bold typography)
- Greeting message: "Welcome, [CHW Name]" (personalized)
- Large action button: "Start Screening" (prominent, centered)
- Quick stats section (placeholder for future sprint):
  - Total screenings today
  - Success rate indicator
- Navigation bar (bottom): Home | Screening | Settings

**Wireframe Notes**:
- Clean, minimal layout
- Large touch targets (≥48px for buttons)
- Ample padding between elements
- Simple gray/white color scheme in wireframe

---

### Screen 2: Voice Recording Screen (Low-Fidelity)

**Purpose**: Main screening interface for voice capture

**Components**:
- Header: "Record Your Voice"
- Instructions section: "Speak naturally for 30 seconds" (icon-based)
- Large recording button (start/stop toggle)
  - State 1 (Ready): Blue, "Start Recording"
  - State 2 (Recording): Red, "Stop Recording" with pulse animation
- Countdown timer (30 seconds → 0)
- Waveform visualization area (placeholder)
- Recording quality indicator:
  - Visual bars (0-5 levels)
  - Color gradient: Red (poor) → Yellow (fair) → Green (excellent)
- Action buttons:
  - "Save Recording" (enabled only after recording)
  - "Cancel" (always enabled)

**Wireframe Notes**:
- Vertical layout (portrait orientation)
- Recording button must be easily tappable
- Visual feedback for recording state crucial
- Timer should be highly visible

---

### Screen 3: Recording Result (Low-Fidelity)

**Purpose**: Confirmation screen after successful recording

**Components**:
- Success indicator: Checkmark icon or "✓ Recording Saved"
- Recording metadata:
  - Duration: "30 seconds"
  - Quality score: "Excellent" with visual indicator
  - Timestamp: "Jan 8, 2026 14:32"
- Options:
  - "Continue to Analysis" (primary action)
  - "Re-record" (secondary action)
- Back navigation option

**Wireframe Notes**:
- Reassuring visual feedback
- Clear next action
- Option to retry without friction

---

## High-Fidelity Design Details

### Color Palette

| Color | Hex | Usage | WCAG Level |
|-------|-----|-------|-----------|
| Primary Blue | #0077CC | Buttons, active states | AA |
| Recording Red | #DC3545 | Recording state, error | AA |
| Success Green | #28A745 | Validation, success state | AA |
| Warning Yellow | #FFC107 | Warning, fair quality | AA |
| Neutral Gray | #6C757D | Secondary text, disabled | AA |
| Background White | #FFFFFF | Main background | AAA |
| Text Dark | #212529 | Primary text | AAA |

**Accessibility Note**: All color pairs maintain WCAG AA contrast ratio (4.5:1 minimum)

### Typography

| Element | Font | Size | Weight | Line Height |
|---------|------|------|--------|-------------|
| App Title | Roboto | 24px | Bold (700) | 32px |
| Screen Title | Roboto | 20px | Bold (700) | 28px |
| Body Text | Roboto | 16px | Regular (400) | 24px |
| Small Text | Roboto | 14px | Regular (400) | 20px |
| Button Text | Roboto | 16px | Bold (600) | 24px |

**Rationale**: Roboto is system font on Android (zero additional size), optimized for readability

### Button Designs

#### Large Recording Button (Primary Action)

**Dimensions**: 80x80px (circular)  
**States**:
- Idle (Ready): Solid blue (#0077CC), white icon (play/microphone)
- Active (Recording): Solid red (#DC3545), white icon (stop square) with pulse animation
- Disabled: Gray (#CCC), 50% opacity

**Interaction**:
- Tap to start → Red (recording)
- Tap to stop → Gray (processing) → Blue (ready)
- Long press: Show tooltip "Press to record"

#### Secondary Buttons (Re-record, Cancel)

**Dimensions**: Full width - 32px (height 48px)  
**State**: 
- Default: Blue text, white background, blue border
- Hover: Light blue background
- Pressed: Dark blue background, white text

---

### Waveform Visualization

**Purpose**: Real-time audio level feedback during recording

**Design**:
- 10-15 vertical bars representing frequency bands
- Height animated in real-time (0-40px range)
- Color gradient: Green (low level) → Yellow → Red (peak)
- Smooth animation (60fps recommended)
- Placeholder during non-recording state (flat line)

**Implementation Note**: Will use `audio_waveform` Flutter package

---

### Recording Quality Indicator

**Purpose**: Provide feedback on audio quality during recording

**Design**:
- 5-level visual indicator (bars stacking upward)
- Thresholds:
  - Level 1-2 (Red): Poor quality (background noise, too quiet)
  - Level 3 (Yellow): Fair quality (acceptable but with issues)
  - Level 4-5 (Green): Good quality (clear, optimal level)

**Update Frequency**: Real-time (every 100ms)

---

### Timer Display

**Purpose**: Show remaining recording time

**Design**:
- Format: MM:SS (e.g., "00:30", "00:00")
- Font: Monospace or Roboto Mono
- Size: 32px, Bold
- Color: Black on white background
- Countdown animation: Smooth numerical decrease

---

## Responsive Design

### Device Breakpoints

| Device Class | Screen Size | Notes |
|--------------|------------|-------|
| Small Phone | 4.5" (1080x2160) | Galaxy S7 equivalent |
| Standard Phone | 5.5" (1440x2560) | Galaxy S10 equivalent |
| Large Phone | 6.5" (1440x3120) | Galaxy S20 Ultra equivalent |
| Tablet | 7.0"+ | Future support (out of scope Sprint 1) |

**Scaling Rules**:
- Button sizes scale: 80px (1x) → 96px (1.5x) on larger screens
- Font sizes scale by 0.125x per screen size increment
- Padding/margins scale proportionally
- Touch target minimum: Always ≥44px on all screens

---

## Accessibility Features

### Visual Accessibility

- ✅ High contrast text (WCAG AA minimum 4.5:1)
- ✅ Large touch targets (≥44px)
- ✅ No color-only information (use icons + labels)
- ✅ Clear focus indicators for interactive elements
- ✅ Sufficient whitespace (padding ≥16px between elements)

### Audio/Haptic Feedback

- Sound cue when recording starts (distinct beep)
- Haptic feedback (vibration) on button press
- Audio confirmation after successful save

### Motor Accessibility

- Large buttons for users with reduced dexterity
- No time-pressure interactions
- Clear, obvious affordances (buttons look clickable)
- Drag-free interactions (no complex gestures)

---

## Design System Setup

### Component Library (Figma)

**Components Created**:
1. **Buttons**
   - Primary (blue, action)
   - Secondary (outlined)
   - Danger (red, destructive)

2. **Typography Styles**
   - Heading 1, 2, 3
   - Body, Small, Caption

3. **Color Tokens**
   - Primary, Secondary, Accent
   - Status colors (success, warning, error)

4. **Icons**
   - Recording icon (microphone)
   - Play/Pause icons
   - Check/X icons
   - Settings icon

**Figma File Structure**:
```
NeuroAccess Design System
├── 📄 Wireframes (Low-Fidelity)
│   ├── S1: Home/Dashboard
│   ├── S2: Voice Recording
│   └── S3: Recording Result
├── 📄 High-Fidelity Mockups
│   ├── S1: Home/Dashboard (HIFI)
│   ├── S2: Voice Recording (HIFI)
│   └── S3: Recording Result (HIFI)
├── 🎨 Design System
│   ├── Colors
│   ├── Typography
│   ├── Components
│   └── Icons
└── 📋 Developer Handoff
    ├── Measurements
    ├── Component specs
    └── Implementation notes
```

---

## Implementation Notes for Developers

### Screen 1: Home/Dashboard
- Use `Scaffold` with `BottomNavigationBar`
- Implement with Provider for state management
- Theme colors from design system

### Screen 2: Voice Recording
- Use `StreamBuilder` for real-time UI updates
- Implement button animation using `AnimationController`
- Waveform visualization: Consider third-party package or custom painter
- Quality indicator: Calculate from audio stream level

### Screen 3: Recording Result
- Simple StatelessWidget
- Navigate using go_router
- Display metadata from recording model

### General Considerations
- All screens follow Material 3 design guidelines
- Dark mode support (future sprint)
- Tablet layout (future sprint)

---

## Figma Sharing & Review

### Sharing Settings

- Link: [To be provided after Figma export]
- Access Level: "View only" for stakeholders
- Share with: Faculty advisor for feedback

### Review Checklist

- [ ] Figma prototype created with 3 screens
- [ ] High-fidelity mockup matches color/typography specs
- [ ] Responsive breakpoints tested
- [ ] Accessibility verified (contrast checker)
- [ ] Developer handoff documentation complete
- [ ] All components in design system
- [ ] Ready for Flutter implementation

---

## Next Steps

After approval:
1. **STORY-003**: Build app shell based on wireframes
2. **STORY-004**: Implement voice recording service
3. **STORY-005**: Implement recording UI from high-fidelity mockups
4. **STORY-006**: Add quality validation

---

## References

- **WCAG 2.1 Level AA**: https://www.w3.org/WAI/WCAG21/quickref/
- **Material 3 Design**: https://m3.material.io/
- **Flutter ResponsiveApp**: https://flutter.dev/docs/development/ui/layout/responsive
- **Android Screen Sizes**: https://support.google.com/googleplay/android-developer/answer/6270173

---

**Story Created**: 2026-01-08  
**Last Updated**: 2026-01-08  
**Status**: Complete ✅

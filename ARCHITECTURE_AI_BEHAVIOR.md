# 🏗️ AI Behavior Detection - Architecture Diagram

## 📐 System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRACTICE SCREEN (UI)                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Camera Preview                         │  │
│  │  ┌────────────────┐                  ┌────────────────┐  │  │
│  │  │ Behavior Badge │                  │ 🤖 AI Toggle  │  │  │
│  │  │   🎯 Tập trung │                  │   ON/OFF      │  │  │
│  │  └────────────────┘                  └────────────────┘  │  │
│  │                                                            │  │
│  │            [User's Face - Real-time Video]                │  │
│  │                                                            │  │
│  │  ┌──────────────────────────────────────────────────┐    │  │
│  │  │  Behavior History Panel (Toggleable)             │    │  │
│  │  │  ┌────────────────────────────────────────────┐  │    │  │
│  │  │  │ 📊 Focus Score: 85/100                     │  │    │  │
│  │  │  │ ✅ Positive: 70%  ❌ Negative: 20%        │  │    │  │
│  │  │  │                                             │  │    │  │
│  │  │  │ Recent Behaviors:                          │  │    │  │
│  │  │  │ • 🎯 Tập trung - 2s ago                   │  │    │  │
│  │  │  │ • 😊 Đang cười - 15s ago                  │  │    │  │
│  │  │  └────────────────────────────────────────────┘  │    │  │
│  │  └──────────────────────────────────────────────────┘    │  │
│  │                                      ┌─────────┐          │  │
│  │                                      │📊 Toggle│          │  │
│  │                                      └─────────┘          │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    PRACTICE CONTROLLER                           │
│  • Manages practice session                                     │
│  • Provides access to CameraService                             │
│  • Coordinates behavior tracking with session data              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      CAMERA SERVICE                              │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  Camera Controller                                         │ │
│  │  • Manages camera hardware                                 │ │
│  │  • Provides image stream                                   │ │
│  └───────────────────────────────────────────────────────────┘ │
│                              │                                   │
│                              ▼                                   │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  AI Behavior Detector Service                              │ │
│  │  • Face detection using ML Kit                             │ │
│  │  • Behavior analysis                                       │ │
│  │  • Statistics calculation                                  │ │
│  │  • Stream-based updates                                    │ │
│  └───────────────────────────────────────────────────────────┘ │
│                              │                                   │
│                    ┌─────────┴─────────┐                        │
│                    ▼                   ▼                         │
│         ┌──────────────────┐  ┌──────────────────┐             │
│         │ Behavior Stream  │  │    Statistics    │             │
│         │  (Real-time)     │  │   (Aggregated)   │             │
│         └──────────────────┘  └──────────────────┘             │
└─────────────────────────────────────────────────────────────────┘
```

## 🔄 Data Flow

```
Camera Image → ML Kit → Face Detection → Behavior Analysis → UI Update
     │                      │                   │                 │
     │                      │                   │                 │
     │                      ▼                   ▼                 ▼
     │              Face Landmarks     BehaviorResult      Badge Widget
     │              • Position         • Label            • Display
     │              • Angles           • Emoji            • Animation
     │              • Expression       • Color            • Update
     │                                 • Type
     │                                 • Confidence
     └─────────────────────────────────────────────────────────────┘
                                       │
                                       ▼
                            ┌──────────────────┐
                            │  Statistics      │
                            │  • Count         │
                            │  • Percentages   │
                            │  • Focus Score   │
                            │  • History       │
                            └──────────────────┘
```

## 🧩 Component Relationships

```
┌─────────────────────────────────────────────────────────────┐
│                    MODELS LAYER                              │
├─────────────────────────────────────────────────────────────┤
│  BehaviorResult                BehaviorStatistics            │
│  • label: String               • behaviorCounts: Map         │
│  • emoji: String               • typeCounts: Map             │
│  • color: Color                • totalDetections: int        │
│  • type: BehaviorType          • focusScore: double          │
│  • timestamp: DateTime         • positivePercentage: double  │
│  • confidence: double          • negativePercentage: double  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   SERVICES LAYER                             │
├─────────────────────────────────────────────────────────────┤
│  AIBehaviorDetectorService                                   │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ Input: CameraImage                                     │  │
│  │   ↓                                                    │  │
│  │ ML Kit Face Detector                                   │  │
│  │   ↓                                                    │  │
│  │ _analyzeBehavior(faces)                                │  │
│  │   ├─ Check smile                                       │  │
│  │   ├─ Check eyes closed                                 │  │
│  │   ├─ Check head pose                                   │  │
│  │   ├─ Detect gestures                                   │  │
│  │   └─ Return BehaviorResult                             │  │
│  │   ↓                                                    │  │
│  │ _updateTracking()                                      │  │
│  │   ↓                                                    │  │
│  │ Output: Stream<BehaviorResult>                         │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  CameraService                                               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ • Camera Controller                                    │  │
│  │ • Behavior Detector (embedded)                         │  │
│  │ • Stream access                                        │  │
│  │ • Statistics getter                                    │  │
│  │ • Toggle control                                       │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  WIDGETS LAYER                               │
├─────────────────────────────────────────────────────────────┤
│  BehaviorBadgeWidget              BehaviorHistoryPanel      │
│  • StreamBuilder                  • Statistics display       │
│  • Animated badge                 • Progress bars            │
│  • Toggle button                  • Recent behaviors list    │
│  • Loading/error states           • Timestamp formatting     │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Behavior Detection Logic

```
┌─────────────────────────────────────────────────────────────┐
│                  BEHAVIOR ANALYSIS TREE                      │
└─────────────────────────────────────────────────────────────┘

                    Face Detected?
                         │
            ┌────────────┴────────────┐
            NO                        YES
            │                         │
            ▼                         ▼
    ❓ No Face               Check Classifications
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
            Smiling? (>0.7)   Eyes Closed?     Head Pose?
                    │                │                │
                    │                │                │
                YES │           YES  │           Analyze
                    ▼                ▼                │
            😊 Smiling      😴 Sleeping        ┌─────┴─────┐
                                               │           │
                                          |yaw|>30°   |roll|>25°
                                               │           │
                                               ▼           ▼
                                      👀 Distracted  ⚠️ Tilted
                                               
                                          pitch>20°
                                               │
                                               ▼
                                          📱 Looking Down
                                               
                                          Gesture?
                                               │
                                    ┌──────────┼──────────┐
                                    │          │          │
                                  STILL     MOVING      NOD
                                    │          │          │
                                    ▼          ▼          ▼
                              ✅ Focused  🤔 Confused  👍 Nod
```

## 📊 Statistics Calculation

```
┌─────────────────────────────────────────────────────────────┐
│                    STATISTICS ENGINE                         │
└─────────────────────────────────────────────────────────────┘

Behavior History (Last 100)
        │
        ▼
┌────────────────────┐
│  Count by Label    │  → behaviorCounts: Map<String, int>
│  • Tập trung: 45   │
│  • Cười: 20        │
│  • Mất tập trung:8 │
└────────────────────┘
        │
        ▼
┌────────────────────┐
│  Count by Type     │  → typeCounts: Map<BehaviorType, int>
│  • Positive: 65    │
│  • Negative: 8     │
│  • Warning: 12     │
│  • Neutral: 15     │
└────────────────────┘
        │
        ▼
┌────────────────────┐
│  Calculate %       │
│  Positive: 65%     │  → positivePercentage
│  Negative: 8%      │  → negativePercentage
└────────────────────┘
        │
        ▼
┌────────────────────┐
│  Focus Score       │
│  Formula:          │  → focusScore (0-100)
│  (P×1 - N×1.5     │
│   - W×0.5)        │
│  / total × 100    │
│  = 85/100         │
└────────────────────┘
```

## 🔄 Update Cycle

```
Every 500ms (2 FPS):

┌─────────────────────────────────────────────────────────────┐
│ 1. Camera captures frame                                     │
│    ↓                                                         │
│ 2. Convert CameraImage → InputImage                          │
│    ↓                                                         │
│ 3. ML Kit processes image (~50-100ms)                        │
│    ↓                                                         │
│ 4. Face detection returns Face objects                       │
│    ↓                                                         │
│ 5. Analyze behavior from face data (~10-20ms)                │
│    ↓                                                         │
│ 6. Create BehaviorResult                                     │
│    ↓                                                         │
│ 7. Update tracking & statistics                              │
│    ↓                                                         │
│ 8. Emit to stream                                            │
│    ↓                                                         │
│ 9. UI receives update via StreamBuilder                      │
│    ↓                                                         │
│ 10. Widget rebuilds with new behavior                        │
│     ↓                                                        │
│ 11. Badge animates and displays new state                    │
│                                                              │
│ Total time: ~60-120ms                                        │
│ Wait: ~380-440ms until next cycle                            │
└─────────────────────────────────────────────────────────────┘
```

## 🎨 UI State Machine

```
AI State Machine:

     ┌─────────┐
     │  OFF    │◄──── Toggle OFF
     └────┬────┘
          │ Toggle ON
          ▼
     ┌─────────┐
     │ LOADING │
     └────┬────┘
          │ Initialize success
          ▼
     ┌─────────┐       ┌───────────┐
     │  READY  │◄─────►│ DETECTING │
     └────┬────┘       └─────┬─────┘
          │                  │
          │ Error            │ Behavior found
          ▼                  ▼
     ┌─────────┐       ┌───────────┐
     │  ERROR  │       │ DISPLAYING│
     └─────────┘       └───────────┘


Badge Display States:

  No Behavior      Behavior        Loading        Error
  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
  │         │    │ 🎯 Tập  │    │ ⏳ Đang │    │ ❌ Lỗi  │
  │  (hide) │    │ trung   │    │ tải AI  │    │ AI      │
  └─────────┘    └─────────┘    └─────────┘    └─────────┘
                      ▲
                      │ Real-time update every 500ms
                      │
```

---

**Legend:**
- `→` : Data flow
- `↓` : Sequential process
- `│` : Connection
- `┌─┐` : Component boundary
- `▼` : Next step

**Created**: March 2026
**Version**: 1.0

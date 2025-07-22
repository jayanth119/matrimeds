# 📱 **Matrimedis**

**Your Virtual Health Assistant – Powered by Flutter**
Matrimedis is a **Flutter-based healthcare application** that helps users access **medicine details, disease info, diet recommendations, and chat support**. It also supports **multi-language** and **voice navigation** for accessibility.

---

## ✅ **Features**

✔ **Medicine Recognition** – Upload or capture medicine image and get details.
✔ **Disease Info** – Search disease, suggested medicines, and recommended food.
✔ **Virtual Doctor (Chatbot)** – Ask health-related queries, get instant short answers, or doctor alert if critical.
✔ **Multi-language** – English, Hindi, Telugu.
✔ **Voice Navigation** – Text-to-Speech for illiterate users.
✔ **HTTP-based API integration** for real-time data.

---

## 🛠 **Tech Stack**

* **Flutter (Dart)** for UI
* **HTTP** for API calls
* **Text-to-Speech (TTS)**
* **Image Picker** for photo capture/upload
* **ML Integration** for medicine recognition & chatbot logic

---

## 🧩 **Diagrams**

### ✅ **Use Case Diagram (Mermaid)**

```mermaid
graph TD
A[User] -->|Upload Photo| B(Medicine Info)
A -->|Capture Photo| B
A -->|Search Disease| C(Disease Info)
A -->|Ask Chatbot| D(Chatbot Service)
A -->|Enable Voice| E(Voice Navigation)

B --> F[Show Medicine Details]
C --> G[Show Disease Details]
C --> H[Suggest Medicines]
C --> I[Suggest Food]
D --> J[Provide Quick Answer]
D --> K[Show Doctor Alert]
E --> L[Text-to-Speech Output]
```

---

### ✅ **Sequence Diagram (Mermaid)**

```mermaid
sequenceDiagram
    participant User
    participant App
    participant API
    participant Chatbot
    participant TTS

    User->>App: Open App
    App->>User: Show Home Screen
    User->>App: Choose Option (Upload/Search/Chat)
    alt Upload Medicine
        App->>API: Send Image
        API->>App: Return Medicine Details
        App->>User: Display Details
    else Search Disease
        App->>API: Send Disease Name
        API->>App: Return Disease Info, Medicines, Food
        App->>User: Display Info
    else Chat Query
        App->>Chatbot: Send Query
        Chatbot->>App: Return Answer or Alert
        App->>User: Show Response
    end
    opt Voice Enabled
        App->>TTS: Convert Text to Speech
        TTS->>User: Voice Output
    end
```

---

## 📺 **Demo Video**

[![Watch the Demo Video](https://img.youtube.com/vi/GdYygz6WhKQgQ5uq/hqdefault.jpg)](https://youtu.be/WQH22xsKI5A?si=GdYygz6WhKQgQ5uq)


---

## 🚀 **How to Run**

```bash
git clone https://github.com/jayanth119/matrimedis.git
cd matrimedis
flutter pub get
flutter run
```

---

## 🌐 **Future Enhancements**

* **AI-based Symptom Checker**
* **Telemedicine Integration**
* **Offline Mode for Medicine Data**

---

## 🏷 **Version**

* **1.0** – Multi-language, Voice Navigation, Chatbot, Medicine & Disease Info.

---

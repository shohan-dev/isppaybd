"""
Quick API Test Script
Run this after starting the server to test functionality.
"""

import requests
import json

BASE_URL = "http://localhost:8000"


def test_health():
    """Test health endpoint"""
    print("🔍 Testing health endpoint...")
    response = requests.get(f"{BASE_URL}/health")
    print(f"✅ Status: {response.status_code}")
    print(f"📊 Response: {json.dumps(response.json(), indent=2)}")
    print()


def test_chat_simple():
    """Test simple chat without history"""
    print("🔍 Testing simple chat...")
    payload = {
        "message": "Hello, can you help me?",
        "history": []
    }
    response = requests.post(f"{BASE_URL}/chat", json=payload)
    print(f"✅ Status: {response.status_code}")
    print(f"💬 Reply: {response.json()['reply']}")
    print()


def test_chat_user_lookup():
    """Test chat with user account lookup"""
    print("🔍 Testing user account lookup...")
    payload = {
        "message": "Can you check my account? My phone is +8801712345678",
        "history": []
    }
    response = requests.post(f"{BASE_URL}/chat", json=payload)
    print(f"✅ Status: {response.status_code}")
    print(f"💬 Reply: {response.json()['reply']}")
    print()


def test_chat_connection_status():
    """Test chat with connection status check"""
    print("🔍 Testing connection status check...")
    payload = {
        "message": "My internet is not working. Phone: +8801823456789",
        "history": [
            "User: Hello",
            "Agent: Hi! How can I help you today?"
        ]
    }
    response = requests.post(f"{BASE_URL}/chat", json=payload)
    print(f"✅ Status: {response.status_code}")
    print(f"💬 Reply: {response.json()['reply']}")
    print()


def test_chat_ticket_creation():
    """Test chat with ticket creation"""
    print("🔍 Testing ticket creation...")
    payload = {
        "message": "I need a technician visit. My router is not working at all.",
        "history": [
            "User: My internet is down",
            "Agent: I've checked your connection and found issues."
        ]
    }
    response = requests.post(f"{BASE_URL}/chat", json=payload)
    print(f"✅ Status: {response.status_code}")
    print(f"💬 Reply: {response.json()['reply']}")
    print()


def test_chat_with_compression():
    """Test chat with long history (compression)"""
    print("🔍 Testing context compression...")
    long_history = [
        "User: Hello",
        "Agent: Hi! How can I help?",
        "User: I'm having internet issues",
        "Agent: Let me check that for you",
        "User: Thank you",
        "Agent: Your connection seems fine now",
        "User: Wait, it's slow again",
        "Agent: Let me investigate further"
    ]
    payload = {
        "message": "Can you create a ticket for this?",
        "history": long_history
    }
    response = requests.post(f"{BASE_URL}/chat", json=payload)
    print(f"✅ Status: {response.status_code}")
    print(f"💬 Reply: {response.json()['reply']}")
    if response.json().get('compressed_context'):
        print(f"🗜️  Compressed: {response.json()['compressed_context']}")
    print()


if __name__ == "__main__":
    print("=" * 60)
    print("🚀 AI SUPPORT AGENT - API TEST SUITE")
    print("=" * 60)
    print()
    
    try:
        test_health()
        test_chat_simple()
        test_chat_user_lookup()
        test_chat_connection_status()
        test_chat_ticket_creation()
        test_chat_with_compression()
        
        print("=" * 60)
        print("✅ ALL TESTS COMPLETED!")
        print("=" * 60)
        
    except requests.exceptions.ConnectionError:
        print("❌ ERROR: Cannot connect to server.")
        print("Make sure the server is running at http://localhost:8000")
        print("Run: ./run.sh or uvicorn app.main:app --reload")
    except Exception as e:
        print(f"❌ ERROR: {e}")

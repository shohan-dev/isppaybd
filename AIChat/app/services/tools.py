from langchain.tools import tool
from app.db.data import get_user_by_name, get_user_by_id, get_all_users

@tool
def search_user_by_name(name: str):
    """Useful for finding a user's details when you have their name. Returns the user dictionary or None."""
    return get_user_by_name(name)

@tool
def search_user_by_id(user_id: int):
    """Useful for finding a user's details when you have their ID. Returns the user dictionary or None."""
    return get_user_by_id(user_id)

@tool
def list_all_users():
    """Returns a list of all users in the database. Use sparingly if the list is long."""
    return get_all_users()

# List of tools to be used by the agent
isp_tools = [search_user_by_name, search_user_by_id, list_all_users]

package com.lms.service;

import com.lms.dao.ContactDAO;
import com.lms.dao.MessageDAO;
import com.lms.model.Message;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;

public class MessageService {

    private final MessageDAO messageDAO = new MessageDAO();
    private final ContactDAO contactDAO = new ContactDAO();

    // ---------------- MESSAGES ----------------

    public void sendMessage(int senderId, int receiverId, String content) throws SQLException {
        // You might want to check privacy settings here (e.g. only contacts can message)
        Message message = new Message();
        message.setSenderId(senderId);
        message.setReceiverId(receiverId);
        message.setContent(content);
        message.setSentAt(LocalDateTime.now());
        message.setRead(false);
        messageDAO.insertMessage(message);
    }

    public List<Message> getConversation(int userId1, int userId2, int limit, int offset) throws SQLException {
        // Fetch paginated messages
        return messageDAO.getConversation(userId1, userId2, limit, offset);
    }

    public void markMessagesAsRead(int senderId, int receiverId) throws SQLException {
        messageDAO.markAsRead(senderId, receiverId);
    }
    
    public int getUnreadMessageCount(int userId) throws SQLException {
        return messageDAO.getUnreadCount(userId);
    }

    public java.util.Map<Integer, Integer> getUnreadCountsPerContact(int userId) throws SQLException {
        return messageDAO.getUnreadCountsPerContact(userId);
    }

    public void deleteMessage(int messageId, int userId) throws SQLException {
        messageDAO.deleteMessage(messageId, userId);
    }

    public void deleteConversation(int user1, int user2) throws SQLException {
        messageDAO.deleteConversation(user1, user2);
    }

    // ---------------- CONTACTS ----------------

    public void sendContactRequest(int senderId, int receiverId) throws SQLException {
        contactDAO.addContactRequest(senderId, receiverId);
    }

    public void acceptContactRequest(int userId, int contactId) throws SQLException {
        contactDAO.updateContactStatus(contactId, userId, "accepted");
    }

    public void declineContactRequest(int userId, int contactId) throws SQLException {
        contactDAO.removeContact(contactId, userId);
    }

    public void removeContact(int userId, int contactId) throws SQLException {
        contactDAO.removeContact(userId, contactId);
    }

    public List<Integer> getMyContacts(int userId) throws SQLException {
        return contactDAO.getAcceptedContacts(userId);
    }

    public List<Integer> getPendingContactRequests(int userId) throws SQLException {
        return contactDAO.getPendingRequests(userId);
    }
}

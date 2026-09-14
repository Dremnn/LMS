<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.lms.model.User, com.lms.model.Message, java.time.format.DateTimeFormatter" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    List<User> contacts = (List<User>) request.getAttribute("contacts");
    User targetUser = (User) request.getAttribute("targetUser");
    List<Message> conversation = (List<Message>) request.getAttribute("conversation");
    DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhắn tin - LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=30">
    <style>
        body { margin: 0; padding: 0; background: #f5f6fa; font-family: 'Segoe UI', Roboto, Arial, sans-serif; overflow: hidden; }
        .chat-container { display: flex; height: calc(100vh - 60px); max-width: 1200px; margin: 0 auto; background: #fff; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); overflow: hidden; margin-top: 20px;}
        
        /* Sidebar (Contacts) */
        .chat-sidebar { width: 320px; border-right: 1px solid #e5e7eb; display: flex; flex-direction: column; background: #fff; }
        .chat-sidebar-header { padding: 20px; border-bottom: 1px solid #e5e7eb; }
        .chat-sidebar-header h3 { margin: 0; font-size: 18px; color: #1f2937; display: flex; justify-content: space-between; align-items: center; }
        .contact-list { flex: 1; overflow-y: auto; }
        .contact-item { display: flex; align-items: center; padding: 15px 20px; border-bottom: 1px solid #f3f4f6; text-decoration: none; color: inherit; transition: background 0.2s; cursor: pointer; }
        .contact-item:hover, .contact-item.active { background: #f9fafb; }
        .contact-avatar { width: 45px; height: 45px; border-radius: 50%; background: #e5e7eb; margin-right: 15px; display: flex; align-items: center; justify-content: center; font-weight: bold; color: #6b7280; font-size: 16px; overflow: hidden; }
        .contact-avatar img { width: 100%; height: 100%; object-fit: cover; }
        .contact-info { flex: 1; }
        .contact-name { font-weight: 600; font-size: 15px; margin-bottom: 3px; color: #111827; }
        .contact-status { font-size: 13px; color: #10b981; }

        /* Main Chat Area */
        .chat-main { flex: 1; display: flex; flex-direction: column; background: #f9fafb; }
        
        /* Header */
        .chat-main-header { padding: 15px 25px; background: #fff; border-bottom: 1px solid #e5e7eb; display: flex; align-items: center; justify-content: space-between; }
        .chat-user-profile { display: flex; align-items: center; }
        .chat-user-profile .contact-avatar { width: 40px; height: 40px; margin-right: 12px; }
        .chat-user-profile .name { font-size: 16px; font-weight: 600; color: #1f2937; }
        .chat-user-profile .status { font-size: 13px; color: #6b7280; }

        /* Messages */
        .chat-messages { flex: 1; overflow-y: auto; padding: 25px; display: flex; flex-direction: column; gap: 15px; }
        .message { max-width: 70%; display: flex; flex-direction: column; }
        .message.sent { align-self: flex-end; }
        .message.received { align-self: flex-start; }
        .msg-bubble { padding: 12px 16px; border-radius: 12px; font-size: 15px; line-height: 1.4; position: relative; }
        .message.received .msg-bubble { background: #fff; border: 1px solid #e5e7eb; color: #1f2937; border-bottom-left-radius: 4px; }
        .message.sent .msg-bubble { background: #2563eb; color: #fff; border-bottom-right-radius: 4px; }
        .msg-time { font-size: 11px; color: #9ca3af; margin-top: 4px; }
        .message.sent .msg-time { align-self: flex-end; }
        .message.received .msg-time { align-self: flex-start; }

        /* Input Area */
        .chat-input-area { padding: 20px 25px; background: #fff; border-top: 1px solid #e5e7eb; display: flex; gap: 15px; align-items: center; }
        .chat-input-area form { width: 100%; display: flex; gap: 10px; align-items: center; }
        .chat-input-area input[type="text"] { flex: 1; padding: 14px 20px; border: 1px solid #d1d5db; border-radius: 25px; font-size: 15px; outline: none; transition: border-color 0.2s; }
        .chat-input-area input[type="text"]:focus { border-color: #2563eb; }
        .send-btn { background: #2563eb; color: #fff; border: none; width: 45px; height: 45px; border-radius: 50%; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 18px; transition: background 0.2s; }
        .send-btn:hover { background: #1d4ed8; }

        .no-chat-selected { display: flex; flex: 1; align-items: center; justify-content: center; flex-direction: column; color: #6b7280; font-size: 16px; }
        .no-chat-selected i { font-size: 48px; margin-bottom: 15px; color: #d1d5db; }
        
        /* Add contact */
        .add-contact-form { padding: 15px 20px; background: #f9fafb; border-bottom: 1px solid #e5e7eb; display: none; }
        .add-contact-form.show { display: flex; gap: 10px; }
        .add-contact-form input { flex: 1; padding: 8px 12px; border: 1px solid #d1d5db; border-radius: 4px; font-size: 14px; }
        .add-contact-form button { padding: 8px 15px; background: #10b981; color: white; border: none; border-radius: 4px; cursor: pointer; }
    </style>
</head>
<body>
    <nav class="lms-navbar">
        <div class="logo">
            <i class="fas fa-graduation-cap"></i>
            <span>HUTECH LMS</span>
        </div>
        <div class="nav-links">
            <a href="<%=request.getContextPath()%>/student/dashboard">Bảng điều khiển</a>
            <a href="<%=request.getContextPath()%>/student/courses">Khóa học của tôi</a>
            <a href="<%=request.getContextPath()%>/student/chat" class="active">Tin nhắn</a>
        </div>
        <div class="user-menu">
            <a href="<%=request.getContextPath()%>/student/wallet" style="margin-right:15px; color:#1f2937; text-decoration:none;">
                <i class="fas fa-wallet"></i> <%= currentUser != null && currentUser.getBalance() != null ? String.format("%,.0f đ", currentUser.getBalance()) : "0 đ" %>
            </a>
            <div class="avatar" style="background-image: url('<%= (currentUser != null && currentUser.getAvatarUrl() != null && !currentUser.getAvatarUrl().isEmpty()) ? currentUser.getAvatarUrl() : "https://ui-avatars.com/api/?name=" + (currentUser != null ? currentUser.getFullName() : "U") %>')"></div>
        </div>
    </nav>

    <div class="chat-container">
        <!-- Sidebar -->
        <div class="chat-sidebar">
            <div class="chat-sidebar-header">
                <h3>Tin nhắn <i class="fas fa-edit" style="color: #2563eb; cursor: pointer;" onclick="toggleAddContact()"></i></h3>
            </div>
            
            <!-- Thêm liên lạc mới -->
            <form class="add-contact-form" id="addContactForm" method="post" action="<%=request.getContextPath()%>/student/chat">
                <input type="hidden" name="action" value="addContact">
                <input type="email" name="email" placeholder="Email người dùng..." required>
                <button type="submit"><i class="fas fa-plus"></i></button>
            </form>

            <div class="contact-list">
                <% if (contacts != null && !contacts.isEmpty()) { 
                    for (User contact : contacts) { 
                        boolean isActive = targetUser != null && targetUser.getId() == contact.getId();
                        String avatar = (contact.getAvatarUrl() != null && !contact.getAvatarUrl().isEmpty()) 
                                        ? contact.getAvatarUrl() 
                                        : "https://ui-avatars.com/api/?name=" + contact.getFullName().replace(" ", "+");
                %>
                    <a href="<%=request.getContextPath()%>/student/chat?targetId=<%=contact.getId()%>" class="contact-item <%= isActive ? "active" : "" %>">
                        <div class="contact-avatar">
                            <img src="<%=avatar%>" alt="<%=contact.getFullName()%>">
                        </div>
                        <div class="contact-info">
                            <div class="contact-name"><%= contact.getFullName() %></div>
                            <div class="contact-status"><i class="fas fa-circle" style="font-size: 8px; margin-right: 4px;"></i> Hoạt động</div>
                        </div>
                    </a>
                <% } } else { %>
                    <div style="padding: 20px; text-align: center; color: #9ca3af; font-size: 14px;">
                        Chưa có cuộc trò chuyện nào.<br>Bấm vào biểu tượng bút để tìm một người bạn.
                    </div>
                <% } %>
            </div>
        </div>

        <!-- Main Chat Area -->
        <div class="chat-main">
            <% if (targetUser != null) { 
                String avatar = (targetUser.getAvatarUrl() != null && !targetUser.getAvatarUrl().isEmpty()) 
                                ? targetUser.getAvatarUrl() 
                                : "https://ui-avatars.com/api/?name=" + targetUser.getFullName().replace(" ", "+");
            %>
                <div class="chat-main-header">
                    <div class="chat-user-profile">
                        <div class="contact-avatar">
                            <img src="<%=avatar%>" alt="<%=targetUser.getFullName()%>">
                        </div>
                        <div>
                            <div class="name"><%= targetUser.getFullName() %></div>
                            <div class="status">Đang hoạt động</div>
                        </div>
                    </div>
                    <div class="chat-actions">
                        <i class="fas fa-ellipsis-v" style="color: #9ca3af; cursor: pointer; padding: 10px;"></i>
                    </div>
                </div>

                <div class="chat-messages" id="chatMessagesBox">
                    <% if (conversation != null && !conversation.isEmpty()) { 
                        for (Message msg : conversation) {
                            boolean isMine = msg.getSenderId() == currentUser.getId();
                    %>
                        <div class="message <%= isMine ? "sent" : "received" %>">
                            <div class="msg-bubble"><%= msg.getContent() %></div>
                            <div class="msg-time"><%= msg.getSentAt().format(timeFormatter) %></div>
                        </div>
                    <% } } else { %>
                        <div style="text-align: center; color: #9ca3af; margin-top: auto; margin-bottom: auto;">
                            Gửi lời chào đến <%= targetUser.getFullName() %>!
                        </div>
                    <% } %>
                </div>

                <div class="chat-input-area">
                    <form action="<%=request.getContextPath()%>/student/chat" method="post">
                        <input type="hidden" name="action" value="send">
                        <input type="hidden" name="targetId" value="<%=targetUser.getId()%>">
                        <i class="far fa-smile" style="font-size: 24px; color: #9ca3af; cursor: pointer;"></i>
                        <i class="fas fa-paperclip" style="font-size: 22px; color: #9ca3af; cursor: pointer; margin-right: 5px;"></i>
                        <input type="text" name="content" placeholder="Nhập tin nhắn của bạn..." required autocomplete="off">
                        <button type="submit" class="send-btn"><i class="fas fa-paper-plane"></i></button>
                    </form>
                </div>

            <% } else { %>
                <div class="no-chat-selected">
                    <i class="far fa-comments"></i>
                    <div>Chọn một liên lạc để bắt đầu trò chuyện</div>
                </div>
            <% } %>
        </div>
    </div>

    <script>
        // Tự động cuộn xuống cuối đoạn chat khi load trang
        var chatBox = document.getElementById("chatMessagesBox");
        if (chatBox) {
            chatBox.scrollTop = chatBox.scrollHeight;
        }

        function toggleAddContact() {
            var form = document.getElementById("addContactForm");
            form.classList.toggle("show");
        }
    </script>
</body>
</html>

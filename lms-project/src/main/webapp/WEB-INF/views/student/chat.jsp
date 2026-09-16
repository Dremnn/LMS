<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.lms.model.User, com.lms.model.Message, java.time.format.DateTimeFormatter" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    String role = currentUser != null ? currentUser.getRole() : "";
    List<User> contacts = (List<User>) request.getAttribute("contacts");
    User targetUser = (User) request.getAttribute("targetUser");
    List<Message> conversation = (List<Message>) request.getAttribute("conversation");
    DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tin nhắn - UTEdu LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=30">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=30">
    <style>
        body { margin: 0; padding: 0; font-family: 'Segoe UI', Roboto, Arial, sans-serif; }
        .chat-container { display: flex; height: calc(100vh - 100px); max-width: 1280px; margin: 16px auto 20px; background: #fff; border-radius: 16px; border: 1px solid var(--border, #E2E8F0); box-shadow: 0 4px 20px rgba(0,0,0,0.06); overflow: hidden; }
        
        /* Sidebar (Contacts) */
        .chat-sidebar { width: 320px; border-right: 1px solid #e5e7eb; display: flex; flex-direction: column; background: #fff; }
        .chat-sidebar-header { padding: 18px 20px; border-bottom: 1px solid #e5e7eb; background: #fff; }
        .chat-sidebar-header h3 { margin: 0; font-size: 17px; color: #1f2937; display: flex; justify-content: space-between; align-items: center; font-weight: 700; }
        .contact-list { flex: 1; overflow-y: auto; }
        .contact-item { display: flex; align-items: center; padding: 14px 18px; border-bottom: 1px solid #f3f4f6; text-decoration: none; color: inherit; transition: background 0.2s; cursor: pointer; }
        .contact-item:hover, .contact-item.active { background: #f0f7ff; }
        .contact-avatar { width: 44px; height: 44px; border-radius: 50%; background: #e5e7eb; margin-right: 14px; display: flex; align-items: center; justify-content: center; font-weight: bold; color: #6b7280; font-size: 15px; overflow: hidden; flex-shrink: 0; }
        .contact-avatar img { width: 100%; height: 100%; object-fit: cover; }
        .contact-info { flex: 1; min-width: 0; }
        .contact-name { font-weight: 600; font-size: 14px; margin-bottom: 3px; color: #111827; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .contact-status { font-size: 12px; color: #10b981; }

        /* Main Chat Area */
        .chat-main { flex: 1; display: flex; flex-direction: column; background: #f9fafb; min-width: 0; }
        
        /* Header */
        .chat-main-header { padding: 14px 22px; background: #fff; border-bottom: 1px solid #e5e7eb; display: flex; align-items: center; justify-content: space-between; }
        .chat-user-profile { display: flex; align-items: center; }
        .chat-user-profile .contact-avatar { width: 40px; height: 40px; margin-right: 12px; }
        .chat-user-profile .name { font-size: 15px; font-weight: 600; color: #1f2937; }
        .chat-user-profile .status { font-size: 12px; color: #6b7280; }

        /* Messages */
        .chat-messages { flex: 1; overflow-y: auto; padding: 22px; display: flex; flex-direction: column; gap: 14px; }
        .message { max-width: 70%; display: flex; flex-direction: column; }
        .message.sent { align-self: flex-end; }
        .message.received { align-self: flex-start; }
        .msg-bubble { padding: 11px 16px; border-radius: 14px; font-size: 14px; line-height: 1.45; position: relative; word-break: break-word; }
        .message.received .msg-bubble { background: #fff; border: 1px solid #e5e7eb; color: #1f2937; border-bottom-left-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.04); }
        .message.sent .msg-bubble { background: #076FA4; color: #fff; border-bottom-right-radius: 4px; }
        .msg-time { font-size: 11px; color: #9ca3af; margin-top: 4px; }
        .message.sent .msg-time { align-self: flex-end; }
        .message.received .msg-time { align-self: flex-start; }

        /* Input Area */
        .chat-input-area { padding: 16px 22px; background: #fff; border-top: 1px solid #e5e7eb; display: flex; gap: 12px; align-items: center; }
        .chat-input-area form { width: 100%; display: flex; gap: 10px; align-items: center; }
        .chat-input-area input[type="text"] { flex: 1; padding: 12px 18px; border: 1px solid #d1d5db; border-radius: 25px; font-size: 14px; outline: none; transition: border-color 0.2s; }
        .chat-input-area input[type="text"]:focus { border-color: #076FA4; }
        .send-btn { background: #076FA4; color: #fff; border: none; width: 42px; height: 42px; border-radius: 50%; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 16px; transition: background 0.2s; flex-shrink: 0; }
        .send-btn:hover { background: #093C62; }

        .no-chat-selected { display: flex; flex: 1; align-items: center; justify-content: center; flex-direction: column; color: #6b7280; font-size: 15px; }
        .no-chat-selected i { font-size: 46px; margin-bottom: 14px; color: #d1d5db; }
        
        /* Add contact */
        .add-contact-form { padding: 12px 18px; background: #f9fafb; border-bottom: 1px solid #e5e7eb; display: none; }
        .add-contact-form.show { display: flex; gap: 10px; }
        .add-contact-form input { flex: 1; padding: 8px 12px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 13px; }
        .add-contact-form button { padding: 8px 14px; background: #076FA4; color: white; border: none; border-radius: 6px; cursor: pointer; }

        /* Dark Theme Support (Chuẩn 5 Dải Màu UTEdu) */
        body.dark-theme .chat-container { background: #182535 !important; border-color: #093C62 !important; box-shadow: 0 4px 20px rgba(0,0,0,0.45) !important; }
        body.dark-theme .chat-sidebar { background: #111312 !important; border-right-color: #093C62 !important; }
        body.dark-theme .chat-sidebar-header { border-bottom-color: #093C62 !important; background: #182535 !important; }
        body.dark-theme .chat-sidebar-header h3 { color: #FFFFFF !important; }
        body.dark-theme .contact-item { border-bottom-color: #182535 !important; color: #FFFFFF !important; }
        body.dark-theme .contact-item:hover, body.dark-theme .contact-item.active { background: #182535 !important; }
        body.dark-theme .contact-name { color: #FFFFFF !important; }
        body.dark-theme .contact-status { color: #38BDF8 !important; }
        body.dark-theme .contact-avatar { background: #182535 !important; color: #9DB9CB !important; border: 1px solid #093C62; }
        body.dark-theme .chat-main { background: #111312 !important; }
        body.dark-theme .chat-main-header { background: #182535 !important; border-bottom-color: #093C62 !important; }
        body.dark-theme .chat-user-profile .name { color: #FFFFFF !important; }
        body.dark-theme .chat-user-profile .status { color: #9DB9CB !important; }
        body.dark-theme .message.received .msg-bubble { background: #182535 !important; border-color: #093C62 !important; color: #FFFFFF !important; }
        body.dark-theme .message.sent .msg-bubble { background: #076FA4 !important; color: #FFFFFF !important; }
        body.dark-theme .msg-time { color: #9DB9CB !important; }
        body.dark-theme .chat-input-area { background: #182535 !important; border-top-color: #093C62 !important; }
        body.dark-theme .chat-input-area input[type="text"] { background: #111312 !important; border-color: #093C62 !important; color: #FFFFFF !important; }
        body.dark-theme .chat-input-area input[type="text"]:focus { border-color: #076FA4 !important; }
        body.dark-theme .send-btn { background: #076FA4 !important; }
        body.dark-theme .send-btn:hover { background: #093C62 !important; }
        body.dark-theme .add-contact-form { background: #182535 !important; border-bottom-color: #093C62 !important; }
        body.dark-theme .add-contact-form input { background: #111312 !important; border-color: #093C62 !important; color: #FFFFFF !important; }
        body.dark-theme .no-chat-selected { color: #9DB9CB !important; }
        body.dark-theme .no-chat-selected i { color: #093C62 !important; }
    </style>
<script type="module" src="https://cdn.jsdelivr.net/npm/emoji-picker-element@^1/index.js"></script>
</head>
<body class="mesh-bg ${cookie.app_theme.value == 'dark' ? 'dark-theme' : ''}">
    <!-- NAVBAR CHUẨN UTEDU LMS -->
    <nav class="lms-navbar">
        <div class="nav-left">
            <a href="<%=request.getContextPath()%>/" class="lms-logo">
                <img src="<%=request.getContextPath()%>/assets/images/utedu-logo.png" alt="UTEdu" class="lms-logo-img" style="height: 36px !important; width: auto; max-height: 36px;">
                <span class="logo-tag">LMS</span>
            </a>
            <% if (currentUser != null) { %>
            <div class="quick-actions">
                <a href="<%=request.getContextPath()%>/chat" class="quick-action-btn active" title="Tin nhắn">
                    <i class="fa-solid fa-comment-dots"></i><span class="quick-action-text">Tin nhắn</span>
                </a>
                <a href="<%=request.getContextPath()%>/notifications" class="quick-action-btn" title="Thông báo">
                    <i class="fa-solid fa-bell"></i><span class="quick-action-text">Thông báo</span>
                </a>
            </div>
            <% } %>
        </div>
        <div class="nav-links">
            <a href="<%=request.getContextPath()%>/courses" class="nav-link">Khóa học</a>
            <% if (currentUser != null) { %>
                <% if ("student".equals(role)) { %>
                    <a href="<%=request.getContextPath()%>/dashboard" class="nav-link">Bảng điều khiển</a>
                    <a href="<%=request.getContextPath()%>/chat" class="nav-link active">Tin nhắn</a>
                <% } %>
                <div class="user-badge">
                    <div class="user-avatar"><%=currentUser.getFullName() != null && !currentUser.getFullName().isEmpty() ? currentUser.getFullName().substring(0,1).toUpperCase() : "U"%></div>
                    <span><%=currentUser.getFullName()%></span>
                    <span class="role-tag"><%=role%></span>
                </div>
                <% if ("instructor".equals(role)) { %>
                    <a href="<%=request.getContextPath()%>/instructor/courses" class="btn btn-outline">Quản lý</a>
                <% } else if ("admin".equals(role)) { %>
                    <a href="<%=request.getContextPath()%>/admin" class="btn btn-outline">Quản trị</a>
                <% } else { %>
                    <a href="<%=request.getContextPath()%>/student/my-courses" class="btn btn-outline">Của tôi</a>
                <% } %>
                <a href="<%=request.getContextPath()%>/student/wallet" class="btn btn-outline" style="border-color:#076FA4; color:#076FA4;">
                    <i class="fa-solid fa-wallet"></i> <%= currentUser.getBalance() != null ? String.format("%,.0f đ", currentUser.getBalance()) : "0 đ" %>
                </a>
                <a href="<%=request.getContextPath()%>/logout" class="btn btn-danger">Đăng xuất</a>
            <% } else { %>
                <a href="<%=request.getContextPath()%>/login" class="btn btn-outline">Đăng nhập</a>
                <a href="<%=request.getContextPath()%>/register" class="btn btn-primary">Đăng ký</a>
            <% } %>
        </div>
    </nav>

    <div class="chat-container">
        <!-- Sidebar -->
        <div class="chat-sidebar">
            <div class="chat-sidebar-header">
                <h3>Tin nhắn <i class="fas fa-edit" style="color: #076FA4; cursor: pointer;" onclick="toggleAddContact()" title="Thêm liên lạc"></i></h3>
            </div>
            
            <% String chatSuccess = (String) session.getAttribute("chatSuccess"); 
               if (chatSuccess != null) { session.removeAttribute("chatSuccess"); %>
                <div style="padding: 10px; margin: 10px; background: #d1fae5; color: #065f46; border-radius: 4px; font-size: 14px;"><%= chatSuccess %></div>
            <% } %>
            <% String chatError = (String) session.getAttribute("chatError"); 
               if (chatError != null) { session.removeAttribute("chatError"); %>
                <div style="padding: 10px; margin: 10px; background: #fee2e2; color: #991b1b; border-radius: 4px; font-size: 14px;"><%= chatError %></div>
            <% } %>

            <!-- Thêm liên lạc mới -->
            <form class="add-contact-form" id="addContactForm" method="post" action="<%=request.getContextPath()%>/chat">
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
                    <a href="<%=request.getContextPath()%>/chat?targetId=<%=contact.getId()%>" class="contact-item <%= isActive ? "active" : "" %>">
                        <div class="contact-avatar">
                            <img src="<%=avatar%>" alt="<%=contact.getFullName()%>">
                        </div>
                        <div class="contact-info">
                                                          <div class="contact-name" style="display:flex; justify-content:space-between; align-items:center;">
                                  <span><%= contact.getFullName() %></span>
                                  <% 
                                      java.util.Map<Integer, Integer> unreadCounts = (java.util.Map<Integer, Integer>) request.getAttribute("unreadCounts");
                                      Integer unread = (unreadCounts != null) ? unreadCounts.get(contact.getId()) : null;
                                      if (unread != null && unread > 0) { 
                                  %>
                                      <span style="background:#3b82f6; color:white; border-radius:50%; font-size:11px; font-weight:bold; width:18px; height:18px; display:inline-flex; align-items:center; justify-content:center;"><%= unread %></span>
                                  <% } %>
                              </div>
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
                        <form method="post" action="<%=request.getContextPath()%>/chat" style="display:inline;" onsubmit="return confirm('Bạn có chắc muốn xóa toàn bộ cuộc hội thoại với <%=targetUser.getFullName()%> không?');">
                            <input type="hidden" name="action" value="deleteConversation">
                            <input type="hidden" name="targetId" value="<%=targetUser.getId()%>">
                            <button type="submit" style="background: none; border: none; cursor: pointer; color: #ef4444;" title="Xóa toàn bộ cuộc hội thoại">
                                <i class="fas fa-trash-alt" style="font-size: 18px;"></i>
                            </button>
                        </form>
                        <i class="fas fa-ellipsis-v" style="color: #9ca3af; cursor: pointer; padding: 10px; margin-left: 10px;"></i>
                    </div>
                </div>

                <div class="chat-messages" id="chatMessagesBox">
                    <% if (conversation != null && !conversation.isEmpty()) { 
                        for (Message msg : conversation) {
                            boolean isMine = msg.getSenderId() == currentUser.getId();
                    %>
                        <div class="message <%= isMine ? "sent" : "received" %>" title="Nhấp chuột trái để xóa tin nhắn này">
                            <div class="msg-bubble" style="cursor: pointer;" data-msg-id="<%=msg.getId()%>" data-target-id="<%=targetUser.getId()%>" onclick="deleteMessage(this.dataset.msgId, this.dataset.targetId)"><%= msg.getContent() %></div>
                            <div class="msg-time"><%= msg.getSentAt().format(timeFormatter) %></div>
                        </div>
                    <% } } else { %>
                        <div style="text-align: center; color: #9ca3af; margin-top: auto; margin-bottom: auto;">
                            Gửi lời chào đến <%= targetUser.getFullName() %>!
                        </div>
                    <% } %>
                </div>

                <div class="chat-input-area">
                    <form action="<%=request.getContextPath()%>/chat" method="post" id="chatForm">
                        <input type="hidden" name="action" value="send">
                        <input type="hidden" name="targetId" value="<%=targetUser.getId()%>">
                                                  <div style="position:relative; display:flex; align-items:center;">
                              <i class="far fa-smile" style="font-size: 24px; color: #9ca3af; cursor: pointer;" id="emojiButton"></i>
                              <div id="emojiPickerContainer" style="display:none; position:absolute; bottom:40px; left:0; z-index:100; box-shadow:0 -2px 10px rgba(0,0,0,0.1); border-radius:8px;">
                                  <emoji-picker style="--num-columns: 8; --emoji-size: 1.5rem;"></emoji-picker>
                              </div>
                          </div>
                          <label style="cursor: pointer; margin-right: 5px; display:flex; align-items:center;" title="Đính kèm">
                              <i class="fas fa-paperclip" style="font-size: 22px; color: #9ca3af;"></i>
                              <input type="file" id="chatFile" style="display:none;" onchange="if(this.value) { document.querySelector('.chat-input-area input[type=text]').value += ' [Đính kèm: ' + this.files[0].name + ']'; document.getElementById('chatInput').focus(); }">
                          </label>
                        <input type="text" id="chatInput" name="content" placeholder="Nhập tin nhắn của bạn..." required autocomplete="off" autofocus>
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

    <!-- Hidden form to delete individual message -->
    <form id="deleteMessageForm" method="post" action="<%=request.getContextPath()%>/chat" style="display: none;">
        <input type="hidden" name="action" value="deleteMessage">
        <input type="hidden" name="messageId" id="delMsgId">
        <input type="hidden" name="targetId" id="delTargetId">
    </form>

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

        function deleteMessage(msgId, targetId) {
            if (confirm("Bạn có chắc chắn muốn xóa tin nhắn này không?")) {
                document.getElementById('delMsgId').value = msgId;
                document.getElementById('delTargetId').value = targetId;
                document.getElementById('deleteMessageForm').submit();
            }        // Prevent multiple submissions on rapid Enter presses
        var chatForm = document.getElementById('chatForm');
        if (chatForm) {
            chatForm.addEventListener('submit', function(e) {
                if (this.dataset.submitted === 'true') {
                    e.preventDefault();
                } else {
                    this.dataset.submitted = 'true';
                }
            });
        }
    }
    </script>

    <!-- Dynamic Island Theme Toggle (Lưu tùy chọn vào Cookie 365 ngày) -->
    <div class="theme-toggle-island" id="themeToggle" title="Chuyển chế độ giao diện">
        <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
        <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
        <span class="toggle-text">Chế độ Tối</span>
    </div>

    <script src="<%=request.getContextPath()%>/assets/js/lms-app.js?v=30"></script>
    <script>
    const emojiButton = document.getElementById('emojiButton');
    const emojiPickerContainer = document.getElementById('emojiPickerContainer');
    const picker = document.querySelector('emoji-picker');
    const chatInput = document.getElementById('chatInput');

    if (emojiButton && emojiPickerContainer && picker) {
        emojiButton.addEventListener('click', function() {
            emojiPickerContainer.style.display = emojiPickerContainer.style.display === 'none' ? 'block' : 'none';
        });

        picker.addEventListener('emoji-click', function(event) {
            chatInput.value += event.detail.unicode;
            chatInput.focus();
            emojiPickerContainer.style.display = 'none';
        });

        document.addEventListener('click', function(e) {
            if (!emojiPickerContainer.contains(e.target) && e.target !== emojiButton) {
                emojiPickerContainer.style.display = 'none';
            }
        });
    }

    // Enter to send toggle
    var enterToggle = document.getElementById('enterToSend');
    if (enterToggle && chatInput) {
        var isEnterToSend = localStorage.getItem('lmsChatEnterToSend') !== 'false';
        enterToggle.checked = isEnterToSend;
        
        enterToggle.addEventListener('change', function() {
            localStorage.setItem('lmsChatEnterToSend', this.checked);
        });

        var isSubmitting = false;
        chatInput.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' && enterToggle.checked) {
                e.preventDefault();
                if (isSubmitting) return;
                isSubmitting = true;
                this.closest('form').submit();
            }
        });

        var chatForm = document.getElementById('chatForm');
        if (chatForm) {
            chatForm.addEventListener('submit', function(e) {
                if (isSubmitting && e.isTrusted) {
                    e.preventDefault();
                    return;
                }
                isSubmitting = true;
                var btn = this.querySelector('button[type="submit"]');
                if (btn) btn.disabled = true;
            });
        }
    }
    </script>

    <!-- Chat Settings Modal -->
    <div id="chatSettingsModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; justify-content:center; align-items:center;">
        <div style="background:#fff; width:350px; border-radius:8px; overflow:hidden; box-shadow:0 4px 20px rgba(0,0,0,0.2);">
            <div style="padding:15px 20px; border-bottom:1px solid #e5e7eb; display:flex; justify-content:space-between; align-items:center; background:#f9fafb;">
                <h3 style="margin:0; font-size:16px; font-weight:600; color:#1f2937;">Cài đặt</h3>
                <button onclick="document.getElementById('chatSettingsModal').style.display='none'" style="background:none; border:none; font-size:20px; cursor:pointer; color:#6b7280;">&times;</button>
            </div>
            <div style="padding:20px;">
                <div style="margin-bottom:20px;">
                    <h4 style="margin:0 0 10px 0; font-size:14px; font-weight:600; color:#1f2937;">Quyền riêng tư</h4>
                    <p style="margin:0 0 10px 0; font-size:13px; color:#6b7280;">Ai có thể nhắn tin cho bạn?</p>
                    <div style="display:flex; align-items:center; margin-bottom:8px;">
                        <input type="radio" id="priv1" name="chatPrivacy" checked style="margin-right:8px;">
                        <label for="priv1" style="font-size:14px; color:#374151;">Chỉ trong Danh bạ của tôi</label>
                    </div>
                    <div style="display:flex; align-items:center;">
                        <input type="radio" id="priv2" name="chatPrivacy" style="margin-right:8px;">
                        <label for="priv2" style="font-size:14px; color:#374151;">Tất cả mọi người</label>
                    </div>
                </div>
                <div style="margin-bottom:20px;">
                    <h4 style="margin:0 0 10px 0; font-size:14px; font-weight:600; color:#1f2937;">Thông tin chung</h4>
                    <div style="display:flex; align-items:center; justify-content:space-between;">
                        <label for="enterToSend" style="font-size:14px; color:#374151;">Dùng phím Enter để gửi</label>
                        <input type="checkbox" id="enterToSend" checked style="width:16px; height:16px;">
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>





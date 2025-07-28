 function showSection(sectionId) {
                var sections = document.getElementsByClassName('content-section');
                for (var i = 0; i < sections.length; i++) {
                    sections[i].style.display = 'none';
                }
                document.getElementById(sectionId).style.display = 'block';
            }
            
document.addEventListener('DOMContentLoaded', function() {
                // Sidebar toggle functionality
                const sidebarToggle = document.querySelector('.sidebar-toggle');
                const navbarSide = document.querySelector('.navbar-side');
                const pageWrapper = document.querySelector('#page-wrapper');
                
                if (sidebarToggle) {
                    sidebarToggle.addEventListener('click', function() {
                        navbarSide.classList.toggle('active');
                        
                        // For mobile view
                        if (window.innerWidth <= 768) {
                            document.body.classList.toggle('sidebar-open');
                        }
                    });
                }
                
                // Handle responsive behavior
                function handleResize() {
                    if (window.innerWidth <= 768) {
                        navbarSide.classList.remove('active');
                        pageWrapper.style.marginLeft = '0';
                    } else {
                        pageWrapper.style.marginLeft = '';
                    }
                }
                
                // Initial call and event listener for resize
                window.addEventListener('resize', handleResize);
                handleResize();
            });  
const canvas = document.getElementById('gameCanvas');
const ctx = canvas.getContext('2d');
const scoreElement = document.getElementById('score');

// إعدادات اللعبة
const gridSize = 20;
let snake = [{x: 10, y: 10}];
let food = {x: 5, y: 5};
let direction = 'right';
let score = 0;
let gameSpeed = 100;

// رسم المربع
function drawRect(x, y, color) {
    ctx.fillStyle = color;
    ctx.fillRect(x * gridSize, y * gridSize, gridSize, gridSize);
}

// رسم اللعبة
function draw() {
    // مسح الشاشة
    ctx.fillStyle = 'black';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    // رسم الأفعى
    snake.forEach(segment => {
        drawRect(segment.x, segment.y, 'lime');
    });
    
    // رسم الطعام
    drawRect(food.x, food.y, 'red');
}

// حركة الأفعى
function moveSnake() {
    const head = {...snake[0]};
    
    // تحديد الاتجاه
    switch(direction) {
        case 'up': head.y--; break;
        case 'down': head.y++; break;
        case 'left': head.x--; break;
        case 'right': head.x++; break;
    }
    
    // التصادم مع الجدران
    if (head.x < 0 || head.x >= canvas.width/gridSize || 
        head.y < 0 || head.y >= canvas.height/gridSize) {
        gameOver();
        return;
    }
    
    // التصادم مع الذات
    if (snake.some(segment => segment.x === head.x && segment.y === head.y)) {
        gameOver();
        return;
    }
    
    // إضافة الرأس الجديد
    snake.unshift(head);
    
    // أكل الطعام
    if (head.x === food.x && head.y === food.y) {
        score += 10;
        scoreElement.textContent = score;
        generateFood();
        
        // زيادة السرعة
        if (gameSpeed > 50) gameSpeed -= 2;
    } else {
        // إزالة الذيل إذا لم يؤكل طعام
        snake.pop();
    }
}

// توليد طعام جديد
function generateFood() {
    food = {
        x: Math.floor(Math.random() * (canvas.width / gridSize)),
        y: Math.floor(Math.random() * (canvas.height / gridSize))
    };
    
    // التأكد أن الطعام لا يظهر على الأفعى
    if (snake.some(segment => segment.x === food.x && segment.y === food.y)) {
        generateFood();
    }
}

// نهاية اللعبة
function gameOver() {
    alert(`Game Over! Score: ${score}`);
    snake = [{x: 10, y: 10}];
    direction = 'right';
    score = 0;
    scoreElement.textContent = score;
    gameSpeed = 100;
    generateFood();
}

// التحكم في الأفعى
document.addEventListener('keydown', (e) => {
    switch(e.key) {
        case 'ArrowUp': if (direction !== 'down') direction = 'up'; break;
        case 'ArrowDown': if (direction !== 'up') direction = 'down'; break;
        case 'ArrowLeft': if (direction !== 'right') direction = 'left'; break;
        case 'ArrowRight': if (direction !== 'left') direction = 'right'; break;
    }
});

// التحكم باللمس للموبايل
let touchStartX = 0;
let touchStartY = 0;

canvas.addEventListener('touchstart', (e) => {
    touchStartX = e.touches[0].clientX;
    touchStartY = e.touches[0].clientY;
    e.preventDefault();
});

canvas.addEventListener('touchmove', (e) => {
    if (!touchStartX || !touchStartY) return;
    
    const touchEndX = e.touches[0].clientX;
    const touchEndY = e.touches[0].clientY;
    
    const diffX = touchStartX - touchEndX;
    const diffY = touchStartY - touchEndY;
    
    if (Math.abs(diffX) > Math.abs(diffY)) {
        // حركة أفقية
        if (diffX > 0 && direction !== 'right') direction = 'left';
        else if (diffX < 0 && direction !== 'left') direction = 'right';
    } else {
        // حركة رأسية
        if (diffY > 0 && direction !== 'down') direction = 'up';
        else if (diffY < 0 && direction !== 'up') direction = 'down';
    }
    
    touchStartX = 0;
    touchStartY = 0;
    e.preventDefault();
});

// دورة اللعبة
function gameLoop() {
    moveSnake();
    draw();
    setTimeout(gameLoop, gameSpeed);
}

// بدء اللعبة
generateFood();
gameLoop();
